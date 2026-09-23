import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:universal_io/io.dart';

import '../exception/failed_parsing_html_exception.dart';
import '../exception/script_evaluation_exception.dart';
import '../mixin/user_agent_mixin.dart';
import '../usecase/headless_webview_use_case.dart';
import 'cloudflare_detector.dart';
import 'script_wrapper.dart';

class _Key extends Equatable {
  final String url;
  final List<String> scripts;
  final bool useCache;
  final Map<String, String> headers;
  final Duration? timeout;

  const _Key({
    required this.url,
    this.scripts = const [],
    required this.useCache,
    this.headers = const {},
    this.timeout,
  });

  @override
  List<Object?> get props => [url, scripts, useCache, headers, timeout];
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
String htmlCacheKey(String url, {List<String> scripts = const []}) {
  if (scripts.isEmpty) return url;
  return [url, ...scripts].join('|');
}

/// Whether this [_fetch] caller may be served from (and written to) the
/// HTML cache. Callers that signal completion over the JS bridge
/// (`image()`, via [signalComplete]) resolve from a bridge payload, not
/// from the HTML string — a cache hit would return before any script runs,
/// so their completer would never fire and the pending future would hang.
bool shouldUseHtmlCache({required bool useCache, Future? signalComplete}) {
  return useCache && signalComplete == null;
}

class HeadlessWebviewManager implements HeadlessWebviewUseCase {
  static const Duration defaultTimeout = Duration(seconds: 15);

  final LogBox _log;
  final HtmlCacheManager _htmlCacheManager;

  final Map<_Key, Future<Document>> _cDocument = {};
  final Map<_Key, Future<String>> _cImage = {};
  final Map<int, HeadlessInAppWebView> _instances = {};

  HeadlessWebviewManager({
    required LogBox log,
    required HtmlCacheManager htmlCacheManager,
  }) : _log = log,
       _htmlCacheManager = htmlCacheManager;

  Future<void> dispose() async {
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
    final key = htmlCacheKey(uri.toString(), scripts: scripts);
    final cacheAllowed = shouldUseHtmlCache(
      useCache: useCache,
      signalComplete: signalComplete,
    );
    final cache = await _htmlCacheManager.getFileFromCache(key);
    final data = await cache?.file.readAsString(encoding: utf8);
    if (data != null && cacheAllowed) {
      delegate.set(uri: uri, html: data, loading: false);
      return data;
    }

    // A Cloudflare challenge sometimes clears on a plain reload, so a
    // challenge-shaped snapshot is retried once in a fresh webview; anything
    // else (null html, timeouts) propagates as before.
    Future<(String, String?)> attempt() async {
      final onLoadStartCompleter = Completer();
      final onLoadStopCompleter = Completer();
      final onLoadErrorCompleter = Completer();

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
          scriptReadyCompleter.safeComplete();
        },
      };

      final webview = HeadlessInAppWebView(
        initialUserScripts: initialUserScripts,
        initialUrlRequest: URLRequest(
          url: uri,
          headers: {
            HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent,
          },
        ),
        initialSettings: InAppWebViewSettings(
          isInspectable: true,
          javaScriptEnabled: true,
          supportZoom: false,
        ),
        onWebViewCreated: (controller) {
          delegate.onWebViewCreated(uri: uri, scripts: scripts);
          for (final handler in handlers.entries) {
            controller.addJavaScriptHandler(
              handlerName: handler.key,
              callback: handler.value,
            );
          }
        },
        onTitleChanged: (_, name) {
          delegate.onTitleChanged(title: name);
        },
        onLoadStart: (_, uri) {
          delegate.onLoadStart(uri: uri?.uriValue);
          onLoadStartCompleter.safeComplete();
        },
        onLoadStop: (_, uri) {
          delegate.onLoadStop(uri: uri?.uriValue);
          onLoadStopCompleter.safeComplete();
        },
        onProgressChanged: (controller, progress) {
          delegate.onProgressChanged(progress: progress);
        },
        onReceivedError: (_, request, error) {
          delegate.onReceivedError(
            request: request.toMap(),
            error: error.toMap(),
          );
          onLoadErrorCompleter.safeComplete();
        },
        onContentSizeChanged: (_, prev, curr) {
          delegate.onContentSizeChanged(previous: prev, current: curr);
        },
        onReceivedHttpError: (_, request, response) {
          delegate.onReceivedHttpError(
            request: request.toMap(),
            response: response.toMap(),
          );
        },
        onLoadResource: (_, resource) {
          delegate.onLoadResource(resource: resource.toMap());
        },
        onConsoleMessage: (controller, message) {
          delegate.onConsoleMessage(message: message.toMap());
        },
        shouldOverrideUrlLoading: (_, action) async {
          final destination = action.request.url;
          final isCloudFlare = action.isCloudFlare(uri);
          delegate.shouldOverrideUrlLoading(
            action: action.toMap(),
            extra: {'is_cloudflare': isCloudFlare},
          );

          if (destination == null) {
            return NavigationActionPolicy.CANCEL;
          }

          final isSame = [
            destination.scheme == uri.scheme,
            destination.host == uri.host,
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

      try {
        await Future.wait([
          webview.run(),
          onLoadStartCompleter.future,
          Future.any([onLoadStopCompleter.future, onLoadErrorCompleter.future]),
        ]).timeout(effectiveTimeout);
      } catch (e, st) {
        delegate.set(error: e, stackTrace: st, loading: false);
        _instances.remove(webview.hashCode);
        await webview.dispose();
        rethrow;
      }

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
        _instances.remove(webview.hashCode);
        await webview.dispose();
        rethrow;
      }

      await webview.dispose();

      _instances.remove(webview.hashCode);

      if (html == null) {
        delegate.set(error: Exception('Null Html'), loading: false);
        throw FailedParsingHtmlException(uri.toString());
      }

      return (html, title);
    }

    final (html, _) = await fetchWithCloudflareRetry(
      url: uri.toString(),
      attemptCount: 2,
      delay: (duration) async {
        _log.log(
          'Cloudflare challenge page detected, retrying in $duration',
          name: 'HeadlessWebviewManager',
        );
        await Future.delayed(duration);
      },
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
}
