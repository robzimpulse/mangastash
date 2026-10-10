/// Headless-webview runtime of core_network: page fetches, image fetches and
/// the JS source script runner.
///
/// Purpose: [HeadlessWebviewManager] loads pages in `HeadlessInAppWebView`s
/// with the platform UA, Cloudflare retry and diagnostics observer plumbing.
/// It implements [HeadlessWebviewUseCase] (`open` → parsed post-JS DOM,
/// `image` → data url) and [RunSourceScriptUseCase] (spec §6): `runOnPage`
/// runs a source function inside a freshly loaded page and caches its JSON
/// result for 30 minutes (cache read/write failures are logged, never fatal);
/// `runOnBlank` runs URL builders in one warm, reused blank webview
/// (serialized; navigations off the blank page are cancelled; rebuilt after
/// a timeout, a platform error, or when found off the blank page). Script-run
/// disposes are bounded by `disposeTimeout`;
/// `evict` drops a URL's cached script results. Every webview — page fetch,
/// script page, warm blank — is built by [HeadlessWebviewManager._createWebview],
/// the single choke point for settings and (later) `hosts` enforcement.
/// Script runs register only the `sourceResult`/`sourceError` JS handlers.
/// Usage: resolve via the locator (`HeadlessWebviewUseCase` /
/// `RunSourceScriptUseCase`, both aliased by `CoreNetworkRegistrar`). Tests
/// may inject `webviewFactory` (defaults to the real `HeadlessInAppWebView`
/// constructor) and `loadSourceCtx` (defaults to the bundled
/// `source_ctx.js` asset).
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui' show Size;

import 'package:core_analytics/core_analytics.dart' hide NavigationAction;
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:mutex/mutex.dart';

import '../exception/failed_parsing_html_exception.dart';
import '../exception/script_evaluation_exception.dart';
import '../script/source_script_exception.dart';
import '../script/source_script_harness.dart';
import '../usecase/headless_webview_use_case.dart';
import '../usecase/run_source_script_use_case.dart';
import 'cloudflare_detector.dart';
import 'script_wrapper.dart';
import 'user_agent_manager.dart';

class _Key extends Equatable {
  final String url;
  final List<String> scripts;
  final List<String> readyWhenSelectors;
  final bool useCache;
  final Map<String, String> headers;
  final Duration? timeout;

  const _Key({
    required this.url,
    this.scripts = const [],
    this.readyWhenSelectors = const [],
    required this.useCache,
    this.headers = const {},
    this.timeout,
  });

  @override
  List<Object?> get props => [
    url,
    scripts,
    readyWhenSelectors,
    useCache,
    headers,
    timeout,
  ];
}

const List<String> _imgExt = [
  'jpeg',
  'jpg',
  'gif',
  'webp',
  'png',
  'ico',
  'bmp',
  'wbmp',
];

/// Completes [completer] from a `resolved` JS-handler call carrying a
/// data-url payload in [args]; every malformed shape (empty args, non-string
/// data, missing mime segment, unsupported extension) completes with an
/// error instead of leaving the caller hanging.
void handleResolvedImage(
  LogBox log,
  Completer<String> completer, {
  required List<dynamic> args,
  required String url,
}) {
  if (args.isEmpty) {
    log.log(
      'Failed to download image [$url]',
      extra: {'url': url, 'args': args},
      name: 'HeadlessWebviewManager',
    );
    completer.safeCompleteError(Exception('Empty response'));
    return;
  }

  final data = args.first;
  if (data is! String) {
    log.log(
      'Failed to download image [$url]',
      extra: {'url': url, 'args': args},
      name: 'HeadlessWebviewManager',
    );
    completer.safeCompleteError(Exception('Invalid response'));
    return;
  }

  final values = data.split(RegExp(r'[:;,]+'));
  // A malformed reader result (empty or non-data url) has no mime
  // segment; treat it as unsupported instead of crashing the handler.
  final ext = values.length > 1 ? values[1].split('/').lastOrNull : null;

  if (ext != null && _imgExt.contains(ext)) {
    log.log(
      'Success download image [$url]',
      name: 'HeadlessWebviewManager',
      extra: {'url': url, 'data': data},
    );
    completer.safeComplete(data);
  } else {
    log.log(
      'Failed download image [$url]',
      name: 'HeadlessWebviewManager',
      error: Exception('Image format $ext not supported'),
      extra: {'url': url, 'args': args},
    );
    completer.safeCompleteError(Exception('Image format $ext not supported'));
  }
}

/// Completes [completer] with an error from a `reject` JS-handler call.
void handleRejectedImage(
  LogBox log,
  Completer<String> completer, {
  required List<dynamic> args,
  required String url,
}) {
  log.log(
    'Failed to download image [$url]',
    name: 'HeadlessWebviewManager',
    extra: {'url': url, 'error': args.toString()},
  );
  completer.safeCompleteError(Exception('Error fetch image'));
}

/// Canonical cache key for the HTML cache: pages loaded with different
/// injected scripts produce different DOMs, so the scripts are part of the
/// key. Both the cache read and write in [_fetch] must go through this —
/// diverging keys mean scripted pages never hit the cache.
///
/// [readyWhenSelectors] also feeds the key: a page whose source declared
/// readiness must never match an entry written by a build that didn't gate
/// on it — such a stale entry is exactly the broken snapshot the gate
/// exists to reject. An empty list keeps the key identical to older builds
/// (nothing was declared, so nothing can be stale about it).
String htmlCacheKey(
  String url, {
  List<String> scripts = const [],
  List<String> readyWhenSelectors = const [],
}) {
  if (scripts.isEmpty && readyWhenSelectors.isEmpty) return url;
  return [
    url,
    ...scripts,
    if (readyWhenSelectors.isNotEmpty) ...['ready', ...readyWhenSelectors],
  ].join('|');
}

/// Whether this [_fetch] caller may be served from (and written to) the
/// HTML cache. Callers that signal completion over the JS bridge
/// (`image()`, via [signalComplete]) resolve from a bridge payload, not
/// from the HTML string — a cache hit would return before any script runs,
/// so their completer would never fire and the pending future would hang.
bool shouldUseHtmlCache({required bool useCache, Future? signalComplete}) {
  return useCache && signalComplete == null;
}

/// Publishes the headless webview's real platform UA into [manager]
/// (first non-empty wins, enforced by `UserAgentManager.publish`).
///
/// Returns whether a UA was actually published: null/empty discoveries and
/// [getUA] failures return false (logged, never thrown) so the caller can
/// retry discovery on a later spawn instead of staying poisoned on the
/// static fallback for the session (review on #183).
Future<bool> publishDiscoveredUserAgent({
  required UserAgentManager manager,
  required Future<String?> Function() getUA,
  required LogBox log,
}) async {
  try {
    final userAgent = await getUA();
    if (userAgent == null || userAgent.trim().isEmpty) {
      return false;
    }
    manager.publish(userAgent);
    return true;
  } catch (e) {
    log.log(
      'Failed to discover webview user agent: $e',
      name: 'HeadlessWebviewManager',
    );
    return false;
  }
}


/// Builds a [HeadlessInAppWebView]; the parameters are the subset of the
/// real constructor this manager uses, so `HeadlessInAppWebView.new` is a
/// valid value. Tests inject fakes through it.
typedef HeadlessWebviewFactory =
    HeadlessInAppWebView Function({
      URLRequest? initialUrlRequest,
      InAppWebViewInitialData? initialData,
      UnmodifiableListView<UserScript>? initialUserScripts,
      InAppWebViewSettings? initialSettings,
      void Function(InAppWebViewController controller)? onWebViewCreated,
      void Function(InAppWebViewController controller, String? title)?
      onTitleChanged,
      void Function(InAppWebViewController controller, WebUri? url)?
      onLoadStart,
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
    });

/// Bundled `ctx` helpers evaluated ahead of every source script.
Future<String> _loadBundledSourceCtx() {
  return rootBundle.loadString('packages/core_network/assets/source_ctx.js');
}

/// A script call waiting for its `sourceResult`/`sourceError` bridge message.
typedef _PendingScript = ({
  Completer<Object?> completer,
  String function,
  String? url,
});

/// Formats [duration] as seconds for timeout messages: `15` for whole
/// seconds, `0.05` otherwise.
String _seconds(Duration duration) {
  if (duration.inMilliseconds % 1000 == 0) return '${duration.inSeconds}';
  return '${duration.inMilliseconds / 1000}';
}

class HeadlessWebviewManager
    implements HeadlessWebviewUseCase, RunSourceScriptUseCase {
  static const Duration defaultTimeout = Duration(seconds: 15);

  /// Upper bound on a script-run webview dispose (and on the warm blank
  /// page's URL check); a hung native call is logged and abandoned.
  static const Duration disposeTimeout = Duration(seconds: 2);

  /// How long a successful script result stays in the JSON result cache.
  static const Duration scriptCacheMaxAge = Duration(minutes: 30);

  /// Document loaded into the warm blank webview used by [runOnBlank].
  static const String _blankPage = '<html><head></head><body></body></html>';

  final LogBox _log;
  final HtmlCacheManager _htmlCacheManager;
  final UserAgentManager? _userAgentManager;
  final HeadlessWebviewFactory _webviewFactory;
  final Future<String> Function() _loadSourceCtx;

  bool _uaDiscoveryStarted = false;

  final Map<_Key, Future<Document>> _cDocument = {};
  final Map<_Key, Future<String>> _cImage = {};
  final Map<int, HeadlessInAppWebView> _instances = {};

  /// Script calls awaiting their bridge message, keyed by call id.
  final Map<String, _PendingScript> _pendingScripts = {};
  int _callSequence = 0;

  /// Memoized `source_ctx.js` contents (loaded on the first script run).
  Future<String>? _sourceCtx;

  /// Warm blank webview shared by [runOnBlank]; null until first use and
  /// after a timeout/platform error discarded it.
  HeadlessInAppWebView? _blankWebview;
  final Mutex _blankMutex = Mutex();

  HeadlessWebviewManager({
    required LogBox log,
    required HtmlCacheManager htmlCacheManager,
    UserAgentManager? userAgentManager,
    HeadlessWebviewFactory webviewFactory = HeadlessInAppWebView.new,
    Future<String> Function() loadSourceCtx = _loadBundledSourceCtx,
  }) : _log = log,
       _htmlCacheManager = htmlCacheManager,
       _userAgentManager = userAgentManager,
       _webviewFactory = webviewFactory,
       _loadSourceCtx = loadSourceCtx;

  Future<void> dispose() async {
    _blankWebview = null;
    await Future.wait([
      for (final instance in _instances.values) instance.dispose(),
    ]);
  }

  @override
  Future<Document> open(
    String url, {
    List<String> scripts = const [],
    List<String> readyWhenSelectors = const [],
    bool useCache = true,
    Duration? timeout,
  }) {
    final key = _Key(
      url: url,
      useCache: useCache,
      scripts: scripts,
      readyWhenSelectors: readyWhenSelectors,
      timeout: timeout,
    );
    return _cDocument.putIfAbsent(
      key,
      () => _open(
        url,
        scripts: scripts,
        readyWhenSelectors: readyWhenSelectors,
        useCache: useCache,
        timeout: timeout,
      ).whenComplete(() {
        _cDocument.remove(key);
      }),
    );
  }

  @override
  Future<String> image(
    String url, {
    bool useCache = true,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    final key = _Key(
      url: url,
      useCache: useCache,
      headers: headers ?? {},
      timeout: timeout,
    );
    return _cImage.putIfAbsent(
      key,
      () => _image(
        url,
        headers: headers,
        useCache: useCache,
        timeout: timeout,
      ).whenComplete(() {
        _cImage.remove(key);
      }),
    );
  }

  @override
  Future<ScriptRunResult> runOnPage({
    required String url,
    required String code,
    required String function,
    required String baseUrl,
    String? searchTerm,
    Duration? timeout,
    bool useCache = true,
    bool captureHtml = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    final key = sourceScriptCacheKey(
      url: url,
      function: function,
      code: code,
      searchTerm: searchTerm,
    );
    // A caller asking for the page HTML needs a real run; a cached value has
    // no page behind it.
    final cacheAllowed = useCache && !captureHtml;

    if (cacheAllowed) {
      // The cache is an optimisation: an unreadable or corrupt entry is a
      // miss, never a failure of a run that could otherwise succeed.
      try {
        final cached = await _htmlCacheManager.getFileFromCache(key);
        final data = await cached?.file.readAsString(encoding: utf8);
        if (data != null) {
          return ScriptRunResult(
            value: jsonDecode(data),
            elapsed: stopwatch.elapsed,
            fromCache: true,
          );
        }
      } catch (e) {
        _log.log(
          'Ignoring unreadable script cache entry [$key]: $e',
          name: 'HeadlessWebviewManager',
        );
      }
    }

    final uri = WebUri(url);
    final delegate = _log.inAppWebviewObserver;
    final effectiveTimeout = timeout ?? defaultTimeout;
    delegate.set(uri: uri, loading: true);

    HeadlessInAppWebView? webview;
    try {
      // Same load stage and Cloudflare retry as page fetches; only the title
      // decides whether the page is a challenge. A challenged page is
      // disposed before the retry loads a fresh one.
      await fetchWithCloudflareRetry(
        url: url,
        attemptCount: 2,
        delay: _cloudflareRetryDelay,
        onExhausted: (error) => delegate.set(error: error, loading: false),
        attempt: () async {
          await _disposeBounded(webview);
          webview = null;
          final loaded = await _loadPage(
            uri: uri,
            delegate: delegate,
            handlers: _scriptHandlers(),
            timeout: effectiveTimeout,
          );
          webview = loaded;
          final title = await loaded.webViewController?.getTitle().timeout(
            effectiveTimeout,
          );
          return ('', title);
        },
      );

      final page = webview!;
      delegate.onRunJavascript(script: code);

      final Object? value;
      try {
        value = await _invoke(
          webview: page,
          code: code,
          function: function,
          baseUrl: baseUrl,
          searchTerm: searchTerm,
          argsJson: '[]',
          pageFunction: true,
          timeout: effectiveTimeout,
          url: url,
        );
      } on SourceScriptException catch (e) {
        if (!captureHtml) rethrow;
        throw e.copyWith(html: await _snapshotHtml(page, effectiveTimeout));
      }

      final html = captureHtml
          ? await _snapshotHtml(page, effectiveTimeout)
          : null;

      if (cacheAllowed) {
        try {
          await _htmlCacheManager.putFile(
            key,
            utf8.encode(jsonEncode(value)),
            fileExtension: 'json',
            maxAge: scriptCacheMaxAge,
          );
        } catch (e) {
          _log.log(
            'Failed to cache script result [$key]: $e',
            name: 'HeadlessWebviewManager',
          );
        }
      }

      delegate.set(loading: false);
      return ScriptRunResult(
        value: value,
        html: html,
        elapsed: stopwatch.elapsed,
      );
    } catch (e, st) {
      delegate.set(error: e, stackTrace: st, loading: false);
      rethrow;
    } finally {
      await _disposeBounded(webview);
    }
  }

  @override
  Future<Object?> runOnBlank({
    required String code,
    required String function,
    required String baseUrl,
    List<Object?> args = const [],
    Duration? timeout,
  }) async {
    final String argsJson;
    try {
      argsJson = jsonEncode(args);
    } catch (e) {
      throw SourceScriptException(
        function: function,
        message: 'Arguments are not JSON-encodable: $e',
      );
    }
    final effectiveTimeout = timeout ?? defaultTimeout;

    return _blankMutex.protect(() async {
      var webview = _blankWebview;
      if (webview == null) {
        try {
          webview = await _warmBlankWebview(effectiveTimeout);
        } on TimeoutException {
          throw SourceScriptException(
            function: function,
            message:
                '$function timed out after ${_seconds(effectiveTimeout)}s '
                'waiting for the blank page to load',
            timedOut: true,
          );
        }
        _blankWebview = webview;
      }

      try {
        final value = await _invoke(
          webview: webview,
          code: code,
          function: function,
          baseUrl: baseUrl,
          argsJson: argsJson,
          pageFunction: false,
          timeout: effectiveTimeout,
        );
        await _discardBlankWebviewIfNavigated(webview);
        return value;
      } on SourceScriptException catch (e) {
        // A script that merely threw leaves the page healthy (unless it
        // navigated away); one that never answered may still be spinning,
        // so the next call gets a fresh page.
        if (e.timedOut) {
          await _discardBlankWebview();
        } else {
          await _discardBlankWebviewIfNavigated(webview);
        }
        rethrow;
      } catch (_) {
        await _discardBlankWebview();
        rethrow;
      }
    });
  }

  @override
  Future<void> evict({required String url}) async {
    final prefix = 'script|$url|';
    final keys = await _htmlCacheManager.keys;
    await Future.wait([
      for (final key in keys)
        if (key.startsWith(prefix)) _htmlCacheManager.removeFile(key),
    ]);
  }

  Future<Document> _open(
    String url, {
    List<String> scripts = const [],
    List<String> readyWhenSelectors = const [],
    bool useCache = true,
    Duration? timeout,
  }) async {
    return parse(
      await _fetch(
        uri: WebUri(url),
        scripts: scripts,
        readyWhenSelectors: readyWhenSelectors,
        delegate: _log.inAppWebviewObserver,
        useCache: useCache,
        timeout: timeout,
      ),
      sourceUrl: url,
    );
  }

  Future<String> _image(
    String url, {
    bool useCache = true,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final Completer<String> completer = Completer();

    String stringHeaders = '';

    if (headers != null) {
      stringHeaders = ', {headers: ${headers.toString()}}';
    }

    await _fetch(
      uri: WebUri(url),
      delegate: _log.inAppWebviewObserver,
      useCache: useCache,
      timeout: timeout,
      scripts: [
        '''
        const toDataURL = url => fetch(url $stringHeaders)
          .then(response => response.blob())
          .then(blob => new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.onerror = reject;
            reader.readAsDataURL(blob);
          }));

        toDataURL('$url').then(
          e => window.flutter_inappwebview.callHandler('resolved', e),
          e => window.flutter_inappwebview.callHandler('reject', e),
        );
        ''',
      ],
      javascriptHandlers: {
        'resolved':
            (args) =>
                handleResolvedImage(_log, completer, args: args, url: url),
        'reject':
            (args) =>
                handleRejectedImage(_log, completer, args: args, url: url),
      },
      signalComplete: completer.future,
    );

    return completer.future;
  }

  /// Loads [uri] in a headless webview, returning its post-JS HTML or the
  /// value of [signalComplete].
  ///
  /// [timeout] bounds both awaited stages independently — the page load,
  /// then the script/snapshot tail (script loop, [signalComplete] wait,
  /// getHtml/getTitle) — so worst-case wall time is `timeout × 2`; the
  /// per-script delays run inside the tail's budget. An upper bound on
  /// liveness, not on total duration.
  Future<String> _fetch({
    required WebUri uri,
    required InAppWebviewObserver delegate,
    UnmodifiableListView<UserScript>? initialUserScripts,
    Map<String, JavaScriptHandlerCallback>? javascriptHandlers,
    List<String> scripts = const [],
    List<String> readyWhenSelectors = const [],
    bool useCache = true,
    Future? signalComplete,
    Duration? timeout,
  }) async {
    delegate.set(uri: uri, loading: true);
    final effectiveTimeout = timeout ?? defaultTimeout;
    final key = htmlCacheKey(
      uri.toString(),
      scripts: scripts,
      readyWhenSelectors: readyWhenSelectors,
    );
    final cacheAllowed = shouldUseHtmlCache(
      useCache: useCache,
      signalComplete: signalComplete,
    );
    // Bridge-signalled callers resolve from the JS payload, never from the
    // cached HTML — skip the read entirely instead of decoding and then
    // discarding the file on every image fetch.
    if (cacheAllowed) {
      final cache = await _htmlCacheManager.getFileFromCache(key);
      final data = await cache?.file.readAsString(encoding: utf8);
      if (data != null) {
        delegate.set(uri: uri, html: data, loading: false);
        return data;
      }
    }

    // A Cloudflare challenge sometimes clears on a plain reload, so a
    // challenge-shaped snapshot is retried once in a fresh webview; anything
    // else (null html, timeouts) propagates as before.
    Future<(String, String?)> attempt() async {
      // Script errors and readiness reports arrive over the bridge —
      // evaluateJavascript neither awaits JS Promises nor reliably surfaces
      // uncaught JS errors. The bridge message can land shortly AFTER
      // evaluateJavascript resolves, so error checks race a short grace
      // window instead of trusting call ordering. Fresh per attempt: a
      // Cloudflare retry re-runs the scripts with clean state.
      ScriptEvaluationException? scriptError;
      final scriptErrorCompleter = Completer<void>();
      final scriptReadyCompleter = Completer<void>();

      final handlers = {
        ...?javascriptHandlers,
        'scriptError': (List<dynamic> args) {
          final report = args.firstOrNull;
          final index = report is Map ? report['script'] : '?';
          final error = report is Map ? report['error'] : args;
          _log.log(
            'Injected script #$index threw: $error',
            name: 'HeadlessWebviewManager',
            extra: {'url': uri.toString(), 'script': index, 'error': error},
          );
          scriptError = ScriptEvaluationException(
            scriptIndex: index is int ? index : -1,
            error: error.toString(),
            url: uri.toString(),
          );
          scriptErrorCompleter.safeComplete();
        },
        'scriptReady': (_) {
          // The beacon's reported boolean is deliberately ignored: the
          // readinessSatisfied() gate over the snapshotted html is the
          // authority on whether the page may be cached — don't "fix" this
          // into an early pass/fail branch.
          scriptReadyCompleter.safeComplete();
        },
      };

      final webview = await _loadPage(
        uri: uri,
        delegate: delegate,
        handlers: handlers,
        timeout: effectiveTimeout,
        initialUserScripts: initialUserScripts,
        scripts: scripts,
      );

      // Everything after the load stage runs under one bounded wait: a wedged
      // renderer that never answers evaluateJavascript/getHtml/getTitle would
      // otherwise hang here forever and, via the dedupe maps' whenComplete,
      // poison every concurrent caller for this URL.
      Future<(String?, String?)> snapshot() async {
        for (final (index, script) in scripts.indexed) {
          if (script.isEmpty) continue;
          await Future.delayed(const Duration(milliseconds: 250));
          // Wrapped so JS errors are reported over the bridge (scriptError)
          // instead of vanishing. The bridge call can land just after
          // evaluateJavascript resolves, hence the grace window.
          await webview.webViewController?.evaluateJavascript(
            source: wrapScript(script, index: index),
          );
          delegate.onRunJavascript(script: script);
          await Future.any([
            scriptErrorCompleter.future,
            Future.delayed(const Duration(milliseconds: 500)),
          ]);
          if (scriptError != null) {
            throw scriptError!;
          }
        }

        if (readyWhenSelectors.isNotEmpty) {
          await webview.webViewController?.evaluateJavascript(
            source: readinessBeaconScript(readyWhenSelectors),
          );
          // Beacons report over the bridge; the snapshot timeout bounds this
          // wait if the beacon never fires.
          await scriptReadyCompleter.future;
        }

        await signalComplete;

        return (
          await webview.webViewController?.getHtml(),
          await webview.webViewController?.getTitle(),
        );
      }

      String? html;
      String? title;
      try {
        (html, title) = await snapshot().timeout(effectiveTimeout);
      } catch (e, st) {
        delegate.set(error: e, stackTrace: st, loading: false);
        await _disposeWebview(webview);
        rethrow;
      }

      await _disposeWebview(webview);

      if (html == null) {
        delegate.set(error: Exception('Null Html'), loading: false);
        throw FailedParsingHtmlException(uri.toString());
      }

      return (html, title);
    }

    final (html, _) = await fetchWithCloudflareRetry(
      url: uri.toString(),
      attemptCount: 2,
      delay: _cloudflareRetryDelay,
      // Parity with the other failure paths: the observer (diagnostics
      // screen) must see the terminal error state when attempts run out,
      // not only the per-attempt ones.
      onExhausted: (error) => delegate.set(error: error, loading: false),
      attempt: attempt,
    );

    // A page whose declared readiness selectors never matched is broken for
    // the caller's purposes — fail instead of caching it for 30 minutes.
    if (!readinessSatisfied(html, readyWhenSelectors)) {
      delegate.set(
        error: Exception(
          'Readiness selectors never matched: $readyWhenSelectors',
        ),
        loading: false,
      );
      throw FailedParsingHtmlException(uri.toString());
    }

    if (cacheAllowed) {
      await _htmlCacheManager.putFile(
        key,
        utf8.encode(html),
        fileExtension: 'html',
        maxAge: const Duration(minutes: 30),
      );
    }

    delegate.set(html: html, loading: false);
    return html;
  }

  /// Logged pause between Cloudflare retry attempts (shared by [_fetch] and
  /// [runOnPage]).
  Future<void> _cloudflareRetryDelay(Duration duration) async {
    _log.log(
      'Cloudflare challenge page detected, retrying in $duration',
      name: 'HeadlessWebviewManager',
    );
    await Future.delayed(duration);
  }

  /// Shared load stage of page fetches and page script runs: builds a
  /// webview for [uri] with [handlers], runs it and waits (bounded by
  /// [timeout]) for load start plus load stop or a load error. Returns the
  /// live webview — the caller owns it and must dispose it via
  /// [_disposeWebview]. On failure the webview is disposed, the observer
  /// gets the error, and the error is rethrown.
  Future<HeadlessInAppWebView> _loadPage({
    required WebUri uri,
    required InAppWebviewObserver delegate,
    required Map<String, JavaScriptHandlerCallback> handlers,
    required Duration timeout,
    UnmodifiableListView<UserScript>? initialUserScripts,
    List<String> scripts = const [],
  }) async {
    final onLoadStartCompleter = Completer();
    final onLoadStopCompleter = Completer();
    final onLoadErrorCompleter = Completer();

    final webview = _createWebview(
      initialUrlRequest: URLRequest(url: uri),
      initialUserScripts: initialUserScripts,
      handlers: handlers,
      delegate: delegate,
      scripts: scripts,
      onLoadStart: () => onLoadStartCompleter.safeComplete(),
      onLoadStop: () => onLoadStopCompleter.safeComplete(),
      onLoadError: () => onLoadErrorCompleter.safeComplete(),
    );

    try {
      await Future.wait([
        webview.run(),
        onLoadStartCompleter.future,
        Future.any([onLoadStopCompleter.future, onLoadErrorCompleter.future]),
      ]).timeout(timeout);
    } catch (e, st) {
      delegate.set(error: e, stackTrace: st, loading: false);
      await _disposeWebview(webview);
      rethrow;
    }

    return webview;
  }

  /// The single construction path for every headless webview (page fetches,
  /// script pages, the warm blank page) and therefore the choke point where
  /// webview settings — and, in a later phase, a script's declared `hosts` —
  /// are enforced. Registers exactly [handlers] on the controller, reports
  /// lifecycle events to [delegate] when given, kicks off platform UA
  /// discovery, and tracks the instance for [dispose]. Pages loaded from
  /// [initialUrlRequest] may only navigate within its scheme+host (Cloudflare
  /// challenge hops excepted); the blank page ([initialData]) installs no
  /// navigation policy so its own load is never cancelled.
  HeadlessInAppWebView _createWebview({
    URLRequest? initialUrlRequest,
    InAppWebViewInitialData? initialData,
    UnmodifiableListView<UserScript>? initialUserScripts,
    required Map<String, JavaScriptHandlerCallback> handlers,
    InAppWebviewObserver? delegate,
    List<String> scripts = const [],
    required void Function() onLoadStart,
    required void Function() onLoadStop,
    required void Function() onLoadError,
  }) {
    final origin = initialUrlRequest?.url;

    final webview = _webviewFactory(
      initialUserScripts: initialUserScripts,
      initialUrlRequest: initialUrlRequest,
      initialData: initialData,
      initialSettings: InAppWebViewSettings(
        isInspectable: true,
        javaScriptEnabled: true,
        supportZoom: false,
      ),
      onWebViewCreated: (controller) {
        if (origin != null) {
          delegate?.onWebViewCreated(uri: origin, scripts: scripts);
        }
        for (final handler in handlers.entries) {
          controller.addJavaScriptHandler(
            handlerName: handler.key,
            callback: handler.value,
          );
        }
        // The headers override is gone so the webview sends its real
        // platform UA; publish it once per manager for Dio to reuse.
        // Fire-and-forget: discovery must never block or fail a fetch.
        // A failed discovery (null/empty/throw) resets the once-guard so
        // the next spawn retries instead of pinning the static fallback.
        final userAgentManager = _userAgentManager;
        if (userAgentManager != null && !_uaDiscoveryStarted) {
          _uaDiscoveryStarted = true;
          unawaited(
            publishDiscoveredUserAgent(
              manager: userAgentManager,
              getUA: () async {
                final userAgent = await controller.evaluateJavascript(
                  source: 'navigator.userAgent',
                );
                return userAgent?.toString();
              },
              log: _log,
            ).then((published) {
              if (!published) {
                _uaDiscoveryStarted = false;
              }
            }),
          );
        }
      },
      onTitleChanged: (_, name) {
        delegate?.onTitleChanged(title: name);
      },
      onLoadStart: (_, uri) {
        delegate?.onLoadStart(uri: uri?.uriValue);
        onLoadStart();
      },
      onLoadStop: (_, uri) {
        delegate?.onLoadStop(uri: uri?.uriValue);
        onLoadStop();
      },
      onProgressChanged: (controller, progress) {
        delegate?.onProgressChanged(progress: progress);
      },
      onReceivedError: (_, request, error) {
        delegate?.onReceivedError(
          request: request.toMap(),
          error: error.toMap(),
        );
        onLoadError();
      },
      onContentSizeChanged: (_, prev, curr) {
        delegate?.onContentSizeChanged(previous: prev, current: curr);
      },
      onReceivedHttpError: (_, request, response) {
        delegate?.onReceivedHttpError(
          request: request.toMap(),
          response: response.toMap(),
        );
      },
      onLoadResource: (_, resource) {
        delegate?.onLoadResource(resource: resource.toMap());
      },
      onConsoleMessage: (controller, message) {
        delegate?.onConsoleMessage(message: message.toMap());
      },
      shouldOverrideUrlLoading:
          origin == null
              // Blank page: only its own about:blank/data load may proceed.
              // A URL builder that navigates must not turn the warm webview
              // into a remote page that later calls (and the bridge) run on.
              ? (_, action) async {
                return _isBlankUrl(action.request.url)
                    ? NavigationActionPolicy.ALLOW
                    : NavigationActionPolicy.CANCEL;
              }
              : (_, action) async {
                final destination = action.request.url;
                final isCloudFlare = action.isCloudFlare(origin);
                delegate?.shouldOverrideUrlLoading(
                  action: action.toMap(),
                  extra: {'is_cloudflare': isCloudFlare},
                );

                if (destination == null) {
                  return NavigationActionPolicy.CANCEL;
                }

                final isSame = [
                  destination.scheme == origin.scheme,
                  destination.host == origin.host,
                ].every((e) => e);

                if (isCloudFlare) {
                  return NavigationActionPolicy.ALLOW;
                }

                return isSame
                    ? NavigationActionPolicy.ALLOW
                    : NavigationActionPolicy.CANCEL;
              },
    );

    _instances[webview.hashCode] = webview;
    return webview;
  }

  /// Whether [url] is still the warm blank page (`about:`/`data:`).
  static bool _isBlankUrl(Uri? url) {
    final scheme = url?.scheme;
    return scheme == 'about' || scheme == 'data';
  }

  /// [_disposeWebview] for script runs: bounded by [disposeTimeout] and
  /// never throwing (logged), so a hung or failing native dispose can
  /// neither hold the warm-blank mutex nor mask the call's real outcome.
  Future<void> _disposeBounded(HeadlessInAppWebView? webview) async {
    try {
      await _disposeWebview(webview)?.timeout(disposeTimeout);
    } catch (e) {
      _log.log(
        'Failed to dispose headless webview: $e',
        name: 'HeadlessWebviewManager',
      );
    }
  }

  /// Untracks and disposes [webview]; null is a no-op.
  Future<void>? _disposeWebview(HeadlessInAppWebView? webview) {
    if (webview == null) return null;
    _instances.remove(webview.hashCode);
    return webview.dispose();
  }

  /// JS handlers for script runs — the only channel a source script has to
  /// the app. Both accept data only and settle the pending call whose
  /// `callId` they carry; unknown/late ids are ignored.
  Map<String, JavaScriptHandlerCallback> _scriptHandlers() {
    return {
      'sourceResult': (List<dynamic> args) {
        _settleScript(args, isError: false);
        return null;
      },
      'sourceError': (List<dynamic> args) {
        _settleScript(args, isError: true);
        return null;
      },
    };
  }

  /// Completes the pending script call addressed by a bridge message.
  void _settleScript(List<dynamic> args, {required bool isError}) {
    final payload = args.firstOrNull;
    if (payload is! Map) return;
    final pending = _pendingScripts[payload['callId']];
    if (pending == null) return;

    if (isError) {
      final message = payload['message']?.toString() ?? 'Unknown error';
      final stack = payload['stack']?.toString() ?? '';
      final location = parseScriptLocation(stack);
      _log.log(
        'Source script ${pending.function} threw: $message',
        name: 'HeadlessWebviewManager',
        extra: {'url': pending.url, 'function': pending.function, 'stack': stack},
      );
      pending.completer.safeCompleteError(
        SourceScriptException(
          function: pending.function,
          message: message,
          line: location?.line,
          column: location?.column,
          url: pending.url,
        ),
      );
      return;
    }

    try {
      pending.completer.safeComplete(jsonDecode('${payload['value']}'));
    } on FormatException catch (e) {
      pending.completer.safeCompleteError(
        SourceScriptException(
          function: pending.function,
          message: 'Invalid result JSON: ${e.message}',
          url: pending.url,
        ),
      );
    }
  }

  /// Evaluates the source harness for [function] in [webview] and awaits its
  /// bridge reply, bounded by [timeout] (evaluation included). A timeout
  /// becomes a [SourceScriptException] with `timedOut: true`; platform errors
  /// propagate unchanged.
  Future<Object?> _invoke({
    required HeadlessInAppWebView webview,
    required String code,
    required String function,
    required String baseUrl,
    String? searchTerm,
    required String argsJson,
    required bool pageFunction,
    required Duration timeout,
    String? url,
  }) async {
    final ctxJs = await _sourceCtxOnce();
    final callId = 'call-${_callSequence++}';
    final completer = Completer<Object?>();
    // The bridge reply can land before evaluateJavascript's own reply; a
    // listener must exist from the start or an early sourceError completes
    // a listener-less future and surfaces as an uncaught (fatal) error. The
    // awaits below still observe the outcome.
    completer.future.ignore();
    _pendingScripts[callId] = (
      completer: completer,
      function: function,
      url: url,
    );

    try {
      return await Future(() async {
        await webview.webViewController?.evaluateJavascript(
          source: buildSourceHarness(
            ctxJs: ctxJs,
            code: code,
            function: function,
            argsJson: argsJson,
            callId: callId,
            baseUrl: baseUrl,
            searchTerm: searchTerm,
            pageFunction: pageFunction,
          ),
        );
        return completer.future;
      }).timeout(timeout);
    } on TimeoutException {
      throw SourceScriptException(
        function: function,
        message: '$function timed out after ${_seconds(timeout)}s',
        url: url,
        timedOut: true,
      );
    } finally {
      _pendingScripts.remove(callId);
    }
  }

  /// Raw page HTML for diagnostics; null when the renderer cannot answer in
  /// [timeout] (never masks the error being reported).
  Future<String?> _snapshotHtml(
    HeadlessInAppWebView webview,
    Duration timeout,
  ) async {
    try {
      return await webview.webViewController?.getHtml().timeout(timeout);
    } catch (e) {
      _log.log(
        'Failed to capture page html: $e',
        name: 'HeadlessWebviewManager',
      );
      return null;
    }
  }

  /// `source_ctx.js`, loaded once and memoized; a failed load is forgotten
  /// so the next script run retries it.
  Future<String> _sourceCtxOnce() {
    return _sourceCtx ??= Future.sync(_loadSourceCtx).catchError((
      Object e,
      StackTrace st,
    ) {
      _sourceCtx = null;
      Error.throwWithStackTrace(e, st);
    });
  }

  /// Builds the warm blank webview for [runOnBlank] and waits (bounded by
  /// [timeout], the calling script's budget) for its page to load; disposed
  /// on failure, rethrowing (a [TimeoutException] on a stuck load).
  Future<HeadlessInAppWebView> _warmBlankWebview(Duration timeout) async {
    final onLoadStopCompleter = Completer();
    final onLoadErrorCompleter = Completer();

    final webview = _createWebview(
      initialData: InAppWebViewInitialData(
        data: _blankPage,
        baseUrl: WebUri('about:blank'),
      ),
      handlers: _scriptHandlers(),
      onLoadStart: () {},
      onLoadStop: () => onLoadStopCompleter.safeComplete(),
      onLoadError: () => onLoadErrorCompleter.safeComplete(),
    );

    try {
      await Future.wait([
        webview.run(),
        Future.any([onLoadStopCompleter.future, onLoadErrorCompleter.future]),
      ]).timeout(timeout);
    } catch (_) {
      await _disposeBounded(webview);
      rethrow;
    }
    return webview;
  }

  /// Disposes and forgets the warm blank webview so the next [runOnBlank]
  /// builds a fresh one.
  Future<void> _discardBlankWebview() async {
    final webview = _blankWebview;
    _blankWebview = null;
    await _disposeBounded(webview);
  }

  /// Discards the warm blank webview when [webview] (the one a call just
  /// used) is no longer on the blank page — e.g. a script navigated
  /// somewhere the navigation policy did not catch — or its URL cannot be
  /// read. Keeps it otherwise.
  Future<void> _discardBlankWebviewIfNavigated(
    HeadlessInAppWebView webview,
  ) async {
    bool blank;
    try {
      final url = await webview.webViewController?.getUrl().timeout(
        disposeTimeout,
      );
      blank = url == null || _isBlankUrl(url);
    } catch (_) {
      blank = false;
    }
    if (!blank) {
      _log.log(
        'Warm blank webview left the blank page; replacing it',
        name: 'HeadlessWebviewManager',
      );
      await _discardBlankWebview();
    }
  }
}
