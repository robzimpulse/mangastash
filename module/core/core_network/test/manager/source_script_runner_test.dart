/// Tests for the JS source script runner in [HeadlessWebviewManager]
/// (`RunSourceScriptUseCase`): the JSON result cache key, cache hits that
/// never build a webview, `captureHtml` bypassing the cache, prefix eviction,
/// and recovery of the warm blank webview after a timeout.
///
/// Purpose: pins the runner behaviour that does not need a real platform
/// webview. Webviews are produced by an injected factory, so the tests can
/// count constructions and hand out fakes whose scripts never answer.
/// Usage: `fvm flutter test test/manager/source_script_runner_test.dart`
/// from module/core/core_network.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/src/manager/headless_webview_manager.dart';
import 'package:core_network/src/manager/visible_webview_guard.dart';
import 'package:core_network/src/script/source_script_exception.dart';
import 'package:core_network/src/usecase/run_source_script_use_case.dart';
import 'package:core_storage/core_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogBox extends Mock implements analytics.LogBox {}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {}

class MockHeadlessWebview extends Mock implements HeadlessInAppWebView {}

class MockWebviewController extends Mock implements InAppWebViewController {}

/// Android render-process callbacks a webview was constructed with.
typedef RenderProcessCallbacks = ({
  InAppWebViewController controller,
  Future<WebViewRenderProcessAction?> Function(
    InAppWebViewController controller,
    WebUri? url,
  )?
  unresponsive,
  void Function(
    InAppWebViewController controller,
    RenderProcessGoneDetail detail,
  )?
  gone,
});

/// Bridge message a fake page posts back for a harness call.
typedef FakeReply = ({String handler, Map<String, Object?> payload});

/// Webview factory that records every construction and returns a fake whose
/// page "loads" on `run()`. Scripts never answer unless [reply] is set; then
/// each evaluated harness gets [reply]'s message (with its `callId`) posted
/// to the registered JS handler, as the real bridge would.
///
/// Knobs: [replyEarly] posts the reply synchronously *before* the
/// `evaluateJavascript` future completes (a device can deliver the bridge
/// message ahead of the evaluate reply); [currentUrl] is what `getUrl()`
/// reports; [disposeHangs] makes `dispose()` never complete; [loadHangs]
/// makes the page never finish loading. Every `shouldOverrideUrlLoading`
/// callback handed to the factory is kept in [policies]. The Android
/// render-process callbacks of each construction are kept in [renderProcess]
/// (same index as [created]); [goneOnRun] makes `run()` report the renderer
/// as gone instead of finishing the load, for the first [goneOnRunCount]
/// constructions.
class FakeWebviewFactory {
  int calls = 0;
  final List<MockHeadlessWebview> created = [];
  final List<
    Future<NavigationActionPolicy?> Function(
      InAppWebViewController controller,
      NavigationAction navigationAction,
    )?
  >
  policies = [];
  FakeReply Function()? reply;
  bool replyEarly = false;
  WebUri? currentUrl = WebUri('about:blank');
  bool disposeHangs = false;
  bool loadHangs = false;
  bool goneOnRun = false;

  /// Registered JS handlers per construction (same index as [created]).
  final List<Map<String, Function>> handlerMaps = [];

  /// Every call id the harness was evaluated with, in order.
  final List<String> callIds = [];

  /// Indexes of constructions whose page never finishes loading.
  final Set<int> loadHangsAt = {};
  int goneOnRunCount = 1;
  final List<RenderProcessCallbacks> renderProcess = [];

  /// `dispose:<index>` for every disposed webview, in order; tests append
  /// `terminate` for every renderer-terminate platform-channel call, so the
  /// relative order is observable.
  final List<String> events = [];

  HeadlessInAppWebView call({
    URLRequest? initialUrlRequest,
    InAppWebViewInitialData? initialData,
    UnmodifiableListView<UserScript>? initialUserScripts,
    InAppWebViewSettings? initialSettings,
    void Function(InAppWebViewController controller)? onWebViewCreated,
    void Function(InAppWebViewController controller, String? title)?
    onTitleChanged,
    void Function(InAppWebViewController controller, WebUri? url)? onLoadStart,
    void Function(InAppWebViewController controller, WebUri? url)? onLoadStop,
    void Function(InAppWebViewController controller, int progress)?
    onProgressChanged,
    void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceError error,
    )?
    onReceivedError,
    void Function(
      InAppWebViewController controller,
      Size oldContentSize,
      Size newContentSize,
    )?
    onContentSizeChanged,
    void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceResponse errorResponse,
    )?
    onReceivedHttpError,
    void Function(InAppWebViewController controller, LoadedResource resource)?
    onLoadResource,
    void Function(
      InAppWebViewController controller,
      ConsoleMessage consoleMessage,
    )?
    onConsoleMessage,
    Future<NavigationActionPolicy?> Function(
      InAppWebViewController controller,
      NavigationAction navigationAction,
    )?
    shouldOverrideUrlLoading,
    Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller,
      WebUri? url,
    )?
    onRenderProcessUnresponsive,
    void Function(
      InAppWebViewController controller,
      RenderProcessGoneDetail detail,
    )?
    onRenderProcessGone,
  }) {
    calls++;
    final index = calls - 1;
    policies.add(shouldOverrideUrlLoading);
    final controller = MockWebviewController();
    final handlers = <String, Function>{};
    handlerMaps.add(handlers);
    when(
      () => controller.addJavaScriptHandler(
        handlerName: any(named: 'handlerName'),
        callback: any(named: 'callback'),
      ),
    ).thenAnswer((invocation) {
      handlers[invocation.namedArguments[#handlerName] as String] =
          invocation.namedArguments[#callback] as Function;
    });
    when(
      () => controller.evaluateJavascript(source: any(named: 'source')),
    ).thenAnswer((invocation) async {
      final source = invocation.namedArguments[#source] as String;
      final callId = RegExp(r'var callId = "([^"]+)"').firstMatch(source);
      final message = reply?.call();
      if (callId != null) callIds.add(callId.group(1)!);
      if (callId != null && message != null) {
        void post() {
          handlers[message.handler]!([
            {'callId': callId.group(1), ...message.payload},
          ]);
        }

        if (replyEarly) {
          post();
          await Future<void>.delayed(const Duration(milliseconds: 20));
        } else {
          scheduleMicrotask(post);
        }
      }
      return null;
    });
    final webview = MockHeadlessWebview();
    when(() => webview.webViewController).thenReturn(controller);
    renderProcess.add((
      controller: controller,
      unresponsive: onRenderProcessUnresponsive,
      gone: onRenderProcessGone,
    ));
    when(() => webview.run()).thenAnswer((_) async {
      onWebViewCreated?.call(controller);
      if (goneOnRun && index < goneOnRunCount) {
        onRenderProcessGone?.call(
          controller,
          RenderProcessGoneDetail(didCrash: false),
        );
        return;
      }
      if (loadHangs || loadHangsAt.contains(index)) return;
      onLoadStart?.call(controller, null);
      onLoadStop?.call(controller, null);
    });
    when(() => webview.dispose()).thenAnswer((_) {
      events.add('dispose:$index');
      return disposeHangs ? Completer<void>().future : Future<void>.value();
    });
    when(() => controller.getUrl()).thenAnswer((_) async => currentUrl);
    when(() => controller.getTitle()).thenAnswer((_) async => 'Page');
    when(() => controller.getHtml()).thenAnswer((_) async => '<html></html>');
    created.add(webview);
    return webview;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLogBox log;
  late MockHtmlCacheManager cache;
  late FakeWebviewFactory factory;
  late HeadlessWebviewManager manager;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(Duration.zero);
    dynamic callback(List<dynamic> _) => null;
    registerFallbackValue(callback);
  });

  setUp(() {
    log = MockLogBox();
    // LogBox.log and inAppWebviewObserver are extensions that write to
    // storage, so a real in-memory Storage is required (see CLAUDE.md).
    when(
      () => log.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    cache = MockHtmlCacheManager();
    factory = FakeWebviewFactory();
    manager = HeadlessWebviewManager(
      log: log,
      htmlCacheManager: cache,
      webviewFactory: factory.call,
      loadSourceCtx: () async => '/*ctx*/',
    );
  });

  group('sourceScriptCacheKey', () {
    test('is stable and follows script|url|function|sha1 shape', () {
      String key() => sourceScriptCacheKey(
        url: 'https://x/p',
        function: 'search',
        code: 'const source = {};',
        searchTerm: 'abc',
      );

      final expectedHash = sha1.convert([
        ...utf8.encode('const source = {};'),
        0,
        ...utf8.encode('abc'),
      ]);
      expect(key(), 'script|https://x/p|search|$expectedHash');
      expect(key(), key());
    });

    test('changes when the code changes', () {
      final a = sourceScriptCacheKey(
        url: 'https://x/p',
        function: 'search',
        code: 'a',
      );
      final b = sourceScriptCacheKey(
        url: 'https://x/p',
        function: 'search',
        code: 'b',
      );
      expect(a, isNot(b));
    });

    test('changes when the search term changes', () {
      final a = sourceScriptCacheKey(
        url: 'https://x/p',
        function: 'search',
        code: 'a',
        searchTerm: 'one',
      );
      final b = sourceScriptCacheKey(
        url: 'https://x/p',
        function: 'search',
        code: 'a',
        searchTerm: 'two',
      );
      expect(a, isNot(b));
    });
  });

  group('runOnPage cache', () {
    test('a cache hit returns the decoded value without a webview', () async {
      const code = 'const source = {search: () => ({items: []})};';
      final key = sourceScriptCacheKey(
        url: 'https://x/p',
        function: 'search',
        code: code,
      );
      final file = await MemoryCacheSystem().createFile('hit.json');
      await file.writeAsString('{"items":[]}');
      when(() => cache.getFileFromCache(key)).thenAnswer(
        (_) async => FileInfo(
          file,
          FileSource.Cache,
          DateTime.now().add(const Duration(minutes: 30)),
          key,
        ),
      );

      final result = await manager.runOnPage(
        url: 'https://x/p',
        code: code,
        function: 'search',
        baseUrl: 'https://x',
      );

      expect(result.value, {'items': []});
      expect(result.fromCache, isTrue);
      expect(result.html, isNull);
      expect(factory.calls, 0);
    });

    test('captureHtml never reads the cache', () async {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);

      // The fake page never answers the script, so the run times out; only
      // the cache interaction matters here.
      await expectLater(
        manager.runOnPage(
          url: 'https://x/p',
          code: 'const source = {};',
          function: 'search',
          baseUrl: 'https://x',
          captureHtml: true,
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.timedOut, 'timedOut', isTrue)
              // No snapshot of a page that never answered: it may still be
              // spinning and would cost another full budget.
              .having((e) => e.html, 'html', isNull),
        ),
      );

      verifyNever(() => cache.getFileFromCache(any()));
      expect(factory.calls, 1);
      verify(() => factory.created.single.dispose()).called(1);
    });
  });

  group('runOnPage bridge', () {
    setUp(() {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
      when(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => MemoryCacheSystem().createFile('put.json'));
    });

    test('decodes the result, caches it as json and disposes', () async {
      factory.reply =
          () => (handler: 'sourceResult', payload: {'value': '{"items":[1]}'});
      const code = 'const source = {};';

      final result = await manager.runOnPage(
        url: 'https://x/p',
        code: code,
        function: 'search',
        baseUrl: 'https://x',
        searchTerm: 'q',
      );

      expect(result.value, {
        'items': [1],
      });
      expect(result.fromCache, isFalse);
      expect(result.html, isNull);
      verify(
        () => cache.putFile(
          sourceScriptCacheKey(
            url: 'https://x/p',
            function: 'search',
            code: code,
            searchTerm: 'q',
          ),
          utf8.encode('{"items":[1]}'),
          fileExtension: 'json',
          maxAge: const Duration(minutes: 30),
        ),
      ).called(1);
      verify(() => factory.created.single.dispose()).called(1);
    });

    test('captureHtml attaches the page html and skips the cache', () async {
      factory.reply = () => (handler: 'sourceResult', payload: {'value': '[]'});

      final result = await manager.runOnPage(
        url: 'https://x/p',
        code: 'const source = {};',
        function: 'images',
        baseUrl: 'https://x',
        captureHtml: true,
      );

      expect(result.value, []);
      expect(result.html, '<html></html>');
      verifyNever(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      );
    });

    test('sourceError maps message and script line, disposes', () async {
      factory.reply =
          () => (
            handler: 'sourceError',
            payload: {
              'message': 'boom',
              'stack':
                  'search@mangastash-source.js:3:7\nglobal code@about:blank',
            },
          );

      await expectLater(
        manager.runOnPage(
          url: 'https://x/p',
          code: 'const source = {};',
          function: 'search',
          baseUrl: 'https://x',
        ),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.message, 'message', 'boom')
              .having((e) => e.line, 'line', 3)
              .having((e) => e.column, 'column', 7)
              .having((e) => e.url, 'url', 'https://x/p')
              .having((e) => e.timedOut, 'timedOut', isFalse)
              .having((e) => e.html, 'html', isNull),
        ),
      );
      verify(() => factory.created.single.dispose()).called(1);
    });
  });

  group('sourceError line fallback (WebKit, issue #115)', () {
    Future<SourceScriptException> failWith(Map<String, Object?> payload) async {
      factory.reply = () => (handler: 'sourceError', payload: payload);
      final error = await manager
          .runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
          )
          .then<Object?>((_) => null, onError: (Object e) => e);
      return error as SourceScriptException;
    }

    test('a stack without a location falls back to the posted line', () async {
      final error = await failWith({
        'message': "Can't find variable: notDefinedFn",
        'stack': 'search@\nglobal code@',
        'line': 61,
        'column': 17,
      });

      expect(error.line, 61);
      expect(error.column, 17);
    });

    test('a numeric double from the bridge is accepted', () async {
      final error = await failWith({
        'message': 'boom',
        'stack': '',
        'line': 4.0,
        'column': 9.0,
      });

      expect(error.line, 4);
      expect(error.column, 9);
    });

    test('the stack location wins over the posted line', () async {
      final error = await failWith({
        'message': 'boom',
        'stack': 'search@mangastash-source.js:3:7',
        'line': 99,
        'column': 99,
      });

      expect(error.line, 3);
      expect(error.column, 7);
    });

    test('a fromHarness error reports no line, even with a stack frame', () async {
      // Chromium keeps the async awaiting script frame in the stack of a
      // ctx-helper error (waitFor timeout); iOS has none. The flag makes
      // both platforms agree: no script line for harness-raised errors.
      final error = await failWith({
        'message': 'waitFor timed out: .x',
        'stack':
            'Error: waitFor timed out\n    at async Object.images '
            '(mangastash-source.js:167:7)',
        'line': 167,
        'column': 7,
        'fromHarness': true,
      });

      expect(error.message, 'waitFor timed out: .x');
      expect(error.line, isNull);
      expect(error.column, isNull);
    });

    test('fromHarness: false keeps the stack location', () async {
      final error = await failWith({
        'message': 'boom',
        'stack': 'search@mangastash-source.js:3:7',
        'fromHarness': false,
      });

      expect(error.line, 3);
      expect(error.column, 7);
    });

    test('no location anywhere leaves the line empty', () async {
      final error = await failWith({'message': 'boom', 'stack': ''});

      expect(error.line, isNull);
      expect(error.column, isNull);
    });
  });

  group('runOnPage timeout', () {
    test('throws a timed-out SourceScriptException and disposes', () async {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);

      final error = await manager
          .runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 50),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<SourceScriptException>());
      final exception = error as SourceScriptException;
      expect(exception.timedOut, isTrue);
      expect(exception.function, 'search');
      expect(exception.url, 'https://x/p');
      expect(exception.message, 'search timed out after 0.05s');
      verify(() => factory.created.single.dispose()).called(1);
      verifyNever(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      );
    });
  });

  group('runOnPage page-load timeout (Android, issue #115)', () {
    // A slow first load used to surface as a raw TimeoutException without the
    // function or URL, so the Fix source / recrawl logic and the error UI had
    // nothing to work with.
    test('a page that never finishes loading is a timed-out '
        'SourceScriptException naming function and url', () async {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
      factory.loadHangs = true;

      final error = await manager
          .runOnPage(
            url: 'https://x/chapter',
            code: 'const source = {};',
            function: 'images',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 50),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<SourceScriptException>());
      final exception = error as SourceScriptException;
      expect(exception.timedOut, isTrue);
      expect(exception.function, 'images');
      expect(exception.url, 'https://x/chapter');
      expect(
        exception.message,
        'images timed out loading the page after 0.05s',
      );
      verify(() => factory.created.single.dispose()).called(1);
    });
  });

  group('script call bridge', () {
    setUp(() {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
    });

    test('call ids are unguessable (secure random, not a counter)', () async {
      for (var i = 0; i < 2; i++) {
        await expectLater(
          manager.runOnBlank(
            code: 'const source = {};',
            function: 'searchUrl',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 30),
          ),
          throwsA(isA<SourceScriptException>()),
        );
      }

      expect(factory.callIds, hasLength(2));
      expect(factory.callIds.toSet(), hasLength(2));
      for (final id in factory.callIds) {
        expect(id, matches(RegExp(r'^call-[0-9a-f]{32}$')));
      }
    });

    test('a webview cannot settle a call another webview owns', () async {
      final blank = manager
          .runOnBlank(
            code: 'const source = {};',
            function: 'searchUrl',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 300),
          )
          .then<Object?>((v) => v, onError: (Object e) => e);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final page = manager
          .runOnPage(
            url: 'https://evil/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://evil',
            timeout: const Duration(milliseconds: 300),
          )
          .then<Object?>((v) => v, onError: (Object e) => e);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(factory.callIds, isNotEmpty);

      // The page webview (index 1) forges a result for the blank call.
      factory.handlerMaps[1]['sourceResult']!([
        {'callId': factory.callIds.first, 'value': '"forged"'},
      ]);

      final blankResult = await blank;
      expect(blankResult, isA<SourceScriptException>());
      expect((blankResult as SourceScriptException).timedOut, isTrue);
      await page;
    });
  });

  group('runOnPage captureHtml after a timeout', () {
    test('does not wait for a second budget to snapshot a spinning page',
        () async {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);

      final error = await manager
          .runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 50),
            captureHtml: true,
          )
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<SourceScriptException>());
      expect((error as SourceScriptException).timedOut, isTrue);
      expect(error.html, isNull);
      verifyNever(() => factory.renderProcess[0].controller.getHtml());
    });
  });

  group('evict', () {
    test('removes only the keys for the given url', () async {
      when(() => cache.keys).thenAnswer(
        (_) async => {
          'script|https://x/p|search|a',
          'script|https://x/q|search|b',
          'https://x/p',
        },
      );
      when(() => cache.removeFile(any())).thenAnswer((_) async {});

      await manager.evict(url: 'https://x/p');

      verify(() => cache.removeFile('script|https://x/p|search|a')).called(1);
      verifyNever(() => cache.removeFile('script|https://x/q|search|b'));
      verifyNever(() => cache.removeFile('https://x/p'));
    });
  });

  group('runOnBlank', () {
    test('a timed-out warm webview is replaced on the next call', () async {
      Future<Object?> run() => manager.runOnBlank(
        code: 'const source = {};',
        function: 'searchUrl',
        baseUrl: 'https://x',
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        run(),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.timedOut, 'timedOut', isTrue)
              .having((e) => e.function, 'function', 'searchUrl'),
        ),
      );
      verify(() => factory.created.first.dispose()).called(1);

      await expectLater(run(), throwsA(isA<SourceScriptException>()));
      expect(factory.calls, 2);
    });

    test('reuses one warm webview across calls, even after a throw', () async {
      Future<Object?> run() => manager.runOnBlank(
        code: 'const source = {};',
        function: 'searchUrl',
        baseUrl: 'https://x',
        args: [
          {'page': 1},
        ],
      );

      factory.reply =
          () => (
            handler: 'sourceResult',
            payload: {'value': '"https://x/browse?page=1"'},
          );
      expect(await run(), 'https://x/browse?page=1');

      factory.reply =
          () => (
            handler: 'sourceError',
            payload: {'message': 'bad', 'stack': ''},
          );
      await expectLater(
        run(),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.message, 'message', 'bad')
              .having((e) => e.line, 'line', isNull),
        ),
      );

      factory.reply =
          () => (handler: 'sourceResult', payload: {'value': 'null'});
      expect(await run(), isNull);

      expect(factory.calls, 1);
      verifyNever(() => factory.created.single.dispose());
    });

    test('registers only the sourceResult/sourceError handlers', () async {
      await expectLater(
        manager.runOnBlank(
          code: 'const source = {};',
          function: 'searchUrl',
          baseUrl: 'https://x',
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<SourceScriptException>()),
      );

      final controller =
          factory.created.single.webViewController! as MockWebviewController;
      final names =
          verify(
            () => controller.addJavaScriptHandler(
              handlerName: captureAny(named: 'handlerName'),
              callback: any(named: 'callback'),
            ),
          ).captured;
      expect(names, unorderedEquals(['sourceResult', 'sourceError']));
    });

    test('loads the source ctx asset only once', () async {
      var loads = 0;
      final counting = HeadlessWebviewManager(
        log: log,
        htmlCacheManager: cache,
        webviewFactory: factory.call,
        loadSourceCtx: () async {
          loads++;
          return '/*ctx*/';
        },
      );
      for (var i = 0; i < 2; i++) {
        await expectLater(
          counting.runOnBlank(
            code: 'const source = {};',
            function: 'searchUrl',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<SourceScriptException>()),
        );
      }
      expect(loads, 1);
    });
  });

  group('bridge reply before evaluateJavascript returns', () {
    setUp(() {
      factory.replyEarly = true;
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
      when(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => MemoryCacheSystem().createFile('put.json'));
    });

    // Without a listener on the call's completer, an early sourceError is an
    // uncaught async error (fatal in the app); flutter_test fails the test.
    test('an early sourceError on a blank run is a normal failure', () async {
      factory.reply =
          () => (
            handler: 'sourceError',
            payload: {'message': 'early', 'stack': ''},
          );
      await expectLater(
        manager.runOnBlank(
          code: 'const source = {};',
          function: 'searchUrl',
          baseUrl: 'https://x',
        ),
        throwsA(
          isA<SourceScriptException>().having(
            (e) => e.message,
            'message',
            'early',
          ),
        ),
      );
    });

    test('an early sourceError on a page run is a normal failure', () async {
      factory.reply =
          () => (
            handler: 'sourceError',
            payload: {'message': 'early', 'stack': ''},
          );
      await expectLater(
        manager.runOnPage(
          url: 'https://x/p',
          code: 'const source = {};',
          function: 'search',
          baseUrl: 'https://x',
        ),
        throwsA(isA<SourceScriptException>()),
      );
    });

    test('an early sourceResult is still returned', () async {
      factory.reply =
          () => (handler: 'sourceResult', payload: {'value': '"https://x/a"'});
      expect(
        await manager.runOnBlank(
          code: 'const source = {};',
          function: 'searchUrl',
          baseUrl: 'https://x',
        ),
        'https://x/a',
      );
    });
  });

  group('warm blank navigation', () {
    Future<Object?> run() => manager.runOnBlank(
      code: 'const source = {};',
      function: 'searchUrl',
      baseUrl: 'https://x',
    );

    setUp(() {
      factory.reply =
          () => (handler: 'sourceResult', payload: {'value': '"https://x/a"'});
    });

    test('cancels every navigation except the initial blank load', () async {
      await run();

      final policy = factory.policies.single;
      expect(policy, isNotNull);
      Future<NavigationActionPolicy?> decide(String url) => policy!(
        MockWebviewController(),
        NavigationAction(
          request: URLRequest(url: WebUri(url)),
          isForMainFrame: true,
        ),
      );
      expect(await decide('about:blank'), NavigationActionPolicy.ALLOW);
      expect(await decide('https://elsewhere/'), NavigationActionPolicy.CANCEL);
      expect(await decide('https://x/a'), NavigationActionPolicy.CANCEL);
    });

    test('a webview that left the blank page is replaced', () async {
      factory.currentUrl = WebUri('https://elsewhere/');
      expect(await run(), 'https://x/a');
      verify(() => factory.created.first.dispose()).called(1);

      factory.currentUrl = WebUri('about:blank');
      expect(await run(), 'https://x/a');
      expect(factory.calls, 2);
      verifyNever(() => factory.created.last.dispose());
    });

    test('a page load timeout is a timed-out SourceScriptException', () async {
      factory.loadHangs = true;
      await expectLater(
        manager.runOnBlank(
          code: 'const source = {};',
          function: 'searchUrl',
          baseUrl: 'https://x',
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.timedOut, 'timedOut', isTrue)
              .having((e) => e.function, 'function', 'searchUrl')
              // Not "searchUrl timed out": the script never ran (offline
              // devices hit this), so it must not read like a script fault.
              .having(
                (e) => e.message,
                'message',
                'searchUrl could not start the script runner '
                    '(blank page did not load after 0.05s)',
              ),
        ),
      );
      verify(() => factory.created.single.dispose()).called(1);
    });
  });

  group('Android render-process recovery (runaway script, issue #115)', () {
    // On Android every WebView of the app shares one renderer process, so a
    // `while(true){}` keeps spinning after the webview is disposed and every
    // later call times out. The platform answer is to terminate the renderer
    // when it reports itself unresponsive and to handle its death
    // (onRenderProcessGone) instead of crashing the app.
    Future<Object?> blankRun({Duration? timeout}) => manager.runOnBlank(
      code: 'const source = {};',
      function: 'searchUrl',
      baseUrl: 'https://x',
      timeout: timeout ?? const Duration(milliseconds: 100),
    );

    Future<WebViewRenderProcessAction?> reportUnresponsive(int index) {
      final callbacks = factory.renderProcess[index];
      return callbacks.unresponsive!(callbacks.controller, null);
    }

    setUp(() {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
    });

    test('the warm blank webview registers both callbacks', () async {
      await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));

      final callbacks = factory.renderProcess.single;
      expect(callbacks.unresponsive, isNotNull);
      expect(callbacks.gone, isNotNull);
    });

    test('a replacement created after a timeout has the callbacks too', () async {
      await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));
      await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));

      expect(factory.renderProcess, hasLength(2));
      for (final callbacks in factory.renderProcess) {
        expect(callbacks.unresponsive, isNotNull);
        expect(callbacks.gone, isNotNull);
      }
    });

    test('an unresponsive blank renderer is terminated', () async {
      final run = blankRun(timeout: const Duration(seconds: 5));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        await reportUnresponsive(0),
        WebViewRenderProcessAction.TERMINATE,
      );
      // Gone arrives next; it must fail the pending call right away.
      factory.renderProcess[0].gone!(
        factory.renderProcess[0].controller,
        RenderProcessGoneDetail(didCrash: false),
      );
      await expectLater(
        run,
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.timedOut, 'timedOut', isTrue)
              .having((e) => e.function, 'function', 'searchUrl')
              .having((e) => e.message, 'message', contains('renderer')),
        ),
      );
    });

    test('a page run is terminated only once its script is running', () async {
      final run = manager
          .runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 300),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);
      // The fake page has loaded; the harness is evaluated after getTitle.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(factory.renderProcess, hasLength(1));
      expect(
        await reportUnresponsive(0),
        WebViewRenderProcessAction.TERMINATE,
      );
      expect(await run, isA<SourceScriptException>());
    });

    test('a page still loading is never terminated (heavy pages)', () async {
      factory.loadHangs = true;
      final run = manager
          .runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 100),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await reportUnresponsive(0), isNull);
      await run;
    });

    test('a renderer that dies discards the warm blank webview', () async {
      factory.reply = () => (handler: 'sourceResult', payload: {'value': '1'});
      expect(await blankRun(), 1);
      expect(factory.calls, 1);

      factory.renderProcess[0].gone!(
        factory.renderProcess[0].controller,
        RenderProcessGoneDetail(didCrash: true),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await blankRun(), 1);
      expect(factory.calls, 2);
      verify(() => factory.created[0].dispose()).called(1);
    });

    test('a renderer that dies while the blank page loads is retried '
        'once on a fresh webview', () async {
      factory.reply = () => (handler: 'sourceResult', payload: {'value': '1'});
      factory.goneOnRun = true;

      expect(await blankRun(), 1);

      expect(factory.calls, 2);
      verify(() => factory.created[0].dispose()).called(1);
    });

    // Chromium's hang monitor needs input events, which a headless webview
    // never gets, so onRenderProcessUnresponsive is not delivered for a
    // script spinning in one (observed on WebView 109, API 33: the renderer
    // kept burning 100% CPU for minutes, and neither input nudges nor
    // chrome://kill navigations stopped it). The plugin has no terminate
    // call either, so MainActivity exposes WebView.getWebViewRenderProcess()
    // .terminate() on a platform channel and the manager calls it whenever a
    // script run times out.
    group('explicit renderer termination (Android)', () {
      const channel = MethodChannel(
        'com.robzimpulse.mangastash/webview_renderer',
      );
      var terminateFails = false;

      setUp(() {
        terminateFails = false;
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              factory.events.add(call.method);
              if (terminateFails) throw PlatformException(code: 'boom');
              return true;
            });
      });
      tearDown(() {
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      test('a timed-out blank call terminates the renderer, then disposes',
          () async {
        await expectLater(
          blankRun(),
          throwsA(
            isA<SourceScriptException>().having(
              (e) => e.timedOut,
              'timedOut',
              isTrue,
            ),
          ),
        );

        expect(factory.events, ['terminate', 'dispose:0']);
      });

      test('a timed-out page script terminates the renderer', () async {
        await expectLater(
          manager.runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(isA<SourceScriptException>()),
        );

        expect(factory.events, ['terminate', 'dispose:0']);
      });

      test('a slow page load never terminates the renderer (heavy pages)',
          () async {
        factory.loadHangs = true;

        await expectLater(
          manager.runOnPage(
            url: 'https://x/p',
            code: 'const source = {};',
            function: 'search',
            baseUrl: 'https://x',
            timeout: const Duration(milliseconds: 50),
          ),
          throwsA(
            isA<SourceScriptException>().having(
              (e) => e.message,
              'message',
              'search timed out loading the page after 0.05s',
            ),
          ),
        );

        expect(factory.events, ['dispose:0']);
      });

      test('a termination fails every in-flight page load at once, and the '
          'failed load does not terminate the new renderer again', () async {
        factory.loadHangsAt.add(0);
        final stopwatch = Stopwatch()..start();
        final pageRun = manager
            .runOnPage(
              url: 'https://x/p',
              code: 'const source = {};',
              function: 'search',
              baseUrl: 'https://x',
              timeout: const Duration(seconds: 30),
            )
            .then<Object?>((_) => null, onError: (Object e) => e);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // Another call (index 1) runs away and is terminated.
        await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));
        final error = await pageRun.timeout(const Duration(seconds: 2));

        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
        expect(error, isA<SourceScriptException>());
        expect(
          (error as SourceScriptException).message,
          contains('renderer'),
        );
        expect(error.timedOut, isTrue);
        expect(error.function, 'search');
        expect(error.url, 'https://x/p');
        expect(factory.events.where((e) => e == 'terminate'), hasLength(1));
        // Both webviews were disposed.
        expect(
          factory.events,
          containsAll(['dispose:0', 'dispose:1']),
        );
      });

      test('a blank page that never loads terminates the renderer too',
          () async {
        factory.loadHangs = true;

        await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));

        expect(factory.events, ['terminate', 'dispose:0']);
      });

      test('a script that merely threw leaves the renderer alone', () async {
        factory.reply =
            () => (handler: 'sourceError', payload: {'message': 'boom'});

        await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));

        expect(factory.events, isNot(contains('terminate')));
      });

      test('a failing termination never masks the timeout', () async {
        terminateFails = true;

        await expectLater(
          blankRun(),
          throwsA(
            isA<SourceScriptException>().having(
              (e) => e.message,
              'message',
              'searchUrl timed out after 0.1s',
            ),
          ),
        );
        expect(factory.events, ['terminate', 'dispose:0']);
      });

      test('an open visible webview suppresses it; the failed call still '
          'disposes and the next call terminates once it is closed',
          () async {
        // The log_box visible screens share the renderer but handle no
        // onRenderProcessGone: terminating under them kills the whole app.
        final guard = VisibleWebviewGuard();
        manager = HeadlessWebviewManager(
          log: log,
          htmlCacheManager: cache,
          webviewFactory: factory.call,
          loadSourceCtx: () async => '/*ctx*/',
          visibleWebviewGuard: guard,
        );
        final session = Completer<void>();
        final visible = guard.track(() => session.future);

        await expectLater(
          blankRun(),
          throwsA(
            isA<SourceScriptException>().having(
              (e) => e.message,
              'message',
              'searchUrl timed out after 0.1s',
            ),
          ),
        );
        expect(factory.events, ['dispose:0']);

        session.complete();
        await visible;
        await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));

        expect(factory.calls, 2);
        expect(factory.events, ['dispose:0', 'terminate', 'dispose:1']);
      });

      test('iOS never asks to terminate', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await expectLater(blankRun(), throwsA(isA<SourceScriptException>()));

        expect(factory.events, ['dispose:0']);
      });
    });

    test('a renderer that keeps dying fails the call, no endless retry', () async {
      factory.goneOnRun = true;
      factory.goneOnRunCount = 10;

      await expectLater(
        blankRun(),
        throwsA(
          isA<SourceScriptException>()
              .having((e) => e.function, 'function', 'searchUrl')
              .having((e) => e.message, 'message', contains('renderer')),
        ),
      );
      expect(factory.calls, 2);
    });
  });

  group('robustness', () {
    setUp(() {
      factory.reply =
          () => (handler: 'sourceResult', payload: {'value': '{"items":[]}'});
    });

    Future<ScriptRunResult> runPage() => manager.runOnPage(
      url: 'https://x/p',
      code: 'const source = {};',
      function: 'search',
      baseUrl: 'https://x',
    );

    test('a failing cache read is a miss', () async {
      when(() => cache.getFileFromCache(any())).thenThrow(Exception('io'));
      when(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => MemoryCacheSystem().createFile('put.json'));

      final result = await runPage();
      expect(result.value, {'items': []});
      expect(result.fromCache, isFalse);
    });

    test('a corrupt cached value is a miss', () async {
      final file = await MemoryCacheSystem().createFile('bad.json');
      await file.writeAsString('{not json');
      when(() => cache.getFileFromCache(any())).thenAnswer(
        (_) async => FileInfo(
          file,
          FileSource.Cache,
          DateTime.now().add(const Duration(minutes: 30)),
          'k',
        ),
      );
      when(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => MemoryCacheSystem().createFile('put.json'));

      final result = await runPage();
      expect(result.value, {'items': []});
      expect(result.fromCache, isFalse);
      expect(factory.calls, 1);
    });

    test('a failing cache write does not fail the run', () async {
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
      when(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenThrow(Exception('disk full'));

      final result = await runPage();
      expect(result.value, {'items': []});
    });

    test('non-JSON args fail as a SourceScriptException future', () async {
      await expectLater(
        manager.runOnBlank(
          code: 'const source = {};',
          function: 'searchUrl',
          baseUrl: 'https://x',
          args: [Object()],
        ),
        throwsA(
          isA<SourceScriptException>().having(
            (e) => e.function,
            'function',
            'searchUrl',
          ),
        ),
      );
      expect(factory.calls, 0);
    });

    test('a hung dispose cannot wedge the warm blank mutex', () async {
      factory.reply = null;
      factory.disposeHangs = true;
      Future<Object?> run() => manager.runOnBlank(
        code: 'const source = {};',
        function: 'searchUrl',
        baseUrl: 'https://x',
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(run(), throwsA(isA<SourceScriptException>()));
      await expectLater(run(), throwsA(isA<SourceScriptException>()));
      expect(factory.calls, 2);
    });

    test('a hung dispose cannot wedge a page run', () async {
      factory.disposeHangs = true;
      when(() => cache.getFileFromCache(any())).thenAnswer((_) async => null);
      when(
        () => cache.putFile(
          any(),
          any(),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((_) async => MemoryCacheSystem().createFile('put.json'));

      expect((await runPage()).value, {'items': []});
    });

    test('a failed source ctx load is retried on the next call', () async {
      var loads = 0;
      final retrying = HeadlessWebviewManager(
        log: log,
        htmlCacheManager: cache,
        webviewFactory: factory.call,
        loadSourceCtx: () async {
          loads++;
          if (loads == 1) throw Exception('asset missing');
          return '/*ctx*/';
        },
      );
      Future<Object?> run() => retrying.runOnBlank(
        code: 'const source = {};',
        function: 'searchUrl',
        baseUrl: 'https://x',
      );

      await expectLater(run(), throwsA(isA<Exception>()));
      expect(await run(), {'items': []});
      expect(loads, 2);
    });
  });

  test('HeadlessWebviewManager is a RunSourceScriptUseCase', () {
    expect(manager, isA<RunSourceScriptUseCase>());
  });
}
