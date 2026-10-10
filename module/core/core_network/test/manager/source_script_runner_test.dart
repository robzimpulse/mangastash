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
import 'package:core_network/src/script/source_script_exception.dart';
import 'package:core_network/src/usecase/run_source_script_use_case.dart';
import 'package:core_storage/core_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogBox extends Mock implements analytics.LogBox {}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {}

class MockHeadlessWebview extends Mock implements HeadlessInAppWebView {}

class MockWebviewController extends Mock implements InAppWebViewController {}

/// Bridge message a fake page posts back for a harness call.
typedef FakeReply = ({String handler, Map<String, Object?> payload});

/// Webview factory that records every construction and returns a fake whose
/// page "loads" on `run()`. Scripts never answer unless [reply] is set; then
/// each evaluated harness gets [reply]'s message (with its `callId`) posted
/// to the registered JS handler, as the real bridge would.
class FakeWebviewFactory {
  int calls = 0;
  final List<MockHeadlessWebview> created = [];
  FakeReply Function()? reply;

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
  }) {
    calls++;
    final controller = MockWebviewController();
    final handlers = <String, Function>{};
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
      if (callId != null && message != null) {
        scheduleMicrotask(() {
          handlers[message.handler]!([
            {'callId': callId.group(1), ...message.payload},
          ]);
        });
      }
      return null;
    });
    final webview = MockHeadlessWebview();
    when(() => webview.webViewController).thenReturn(controller);
    when(() => webview.run()).thenAnswer((_) async {
      onWebViewCreated?.call(controller);
      onLoadStart?.call(controller, null);
      onLoadStop?.call(controller, null);
    });
    when(() => webview.dispose()).thenAnswer((_) async {});
    when(() => controller.getTitle()).thenAnswer((_) async => 'Page');
    when(() => controller.getHtml()).thenAnswer((_) async => '<html></html>');
    created.add(webview);
    return webview;
  }
}

void main() {
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
              .having((e) => e.html, 'html', '<html></html>'),
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

  test('HeadlessWebviewManager is a RunSourceScriptUseCase', () {
    expect(manager, isA<RunSourceScriptUseCase>());
  });
}
