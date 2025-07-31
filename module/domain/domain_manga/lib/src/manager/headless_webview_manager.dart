import 'dart:async';
import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';
import 'package:universal_io/io.dart';

class HeadlessWebviewManager {
  final LogBox _log;
  final CustomCacheManager _cacheManager;

  HeadlessWebviewManager({
    required LogBox log,
    required CustomCacheManager cacheManager,
  }) : _log = log,
       _cacheManager = cacheManager;

  Future<Document?> open(
    String url, {
    List<String> scripts = const [],
    bool useCache = true,
  }) async {
    final uri = WebUri(url);
    final html = await _fetch(
      uri: uri,
      scripts: scripts,
      useCache: useCache,
      delegate: _log.inAppWebviewObserver,
    );
    if (html == null) return null;
    return parse(html);
  }

  Future<String?> _fetch({
    required WebUri uri,
    required InAppWebviewObserver delegate,
    List<String> scripts = const [],
    bool useCache = true,
  }) async {
    final cache = await _cacheManager.html.getFileFromCache(uri.toString());
    final data = await cache?.file.readAsString();

    if (data != null && useCache) {
      delegate.set(uri: uri, html: data, loading: false);
      return data;
    }
    final onLoadStartCompleter = Completer();
    final onLoadStopCompleter = Completer();
    final onLoadErrorCompleter = Completer();

    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: uri,
        headers: {HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent},
      ),
      initialSettings: InAppWebViewSettings(
        isInspectable: true,
        javaScriptEnabled: true,
        supportZoom: false,
      ),
      onWebViewCreated: (_) {
        delegate.onWebViewCreated(uri: uri, scripts: scripts);
      },
      onLoadStart: (_, uri) {
        delegate.onLoadStart(uri: uri?.uriValue);
        onLoadStartCompleter.safeComplete();
      },
      onLoadStop: (_, uri) {
        delegate.onLoadStop(uri: uri?.uriValue);
        onLoadStopCompleter.safeComplete();
      },
      onReceivedError: (_, request, error) {
        delegate.onReceivedError(
          message: error.description,
          extra: {'request': request.toMap(), 'error': error.toMap()},
        );
        onLoadErrorCompleter.safeComplete();
      },
      onContentSizeChanged: (_, prev, curr) {
        delegate.onContentSizeChanged(previous: prev, current: curr);
      },
      onProgressChanged: (_, progress) {
        delegate.onProgressChanged(progress: progress);
      },
      onConsoleMessage: (_, message) {
        delegate.onConsoleMessage(extra: message.toMap());
      },
      onAjaxProgress: (_, request) async {
        delegate.onAjaxRequest(extra: request.toMap());
        return AjaxRequestAction.PROCEED;
      },
      onAjaxReadyStateChange: (_, request) async {
        delegate.onAjaxRequest(extra: request.toMap());
        return null;
      },
      shouldOverrideUrlLoading: (_, action) async {
        final destination = action.request.url;

        delegate.shouldOverrideUrlLoading(extra: action.toMap());

        if (destination == null) {
          return NavigationActionPolicy.CANCEL;
        }

        final isSame = [
          destination.scheme == uri.scheme,
          destination.host == uri.host,
        ].every((e) => e);

        return isSame
            ? NavigationActionPolicy.ALLOW
            : NavigationActionPolicy.CANCEL;
      },
    );

    await Future.wait([
      webview.run(),
      onLoadStartCompleter.future,
      Future.any([
        onLoadStopCompleter.future,
        onLoadErrorCompleter.future,
        Future.delayed(const Duration(seconds: 15)),
      ]),
    ]);

    for (final script in scripts) {
      if (script.isEmpty) continue;
      await Future.delayed(const Duration(seconds: 1));
      await webview.webViewController?.evaluateJavascript(source: script);
      delegate.onRunJavascript(script: script);
    }

    final html = await webview.webViewController?.getHtml();

    await webview.dispose();

    if (html == null) {
      delegate.set(error: Exception('Null Html'), loading: false);
      return null;
    }

    await _cacheManager.html.putFile(
      uri.toString(),
      utf8.encode(html),
      fileExtension: 'html',
      maxAge: const Duration(minutes: 30),
    );

    delegate.set(html: html, loading: false);
    return html;
  }

  Future<void> dispose() async {
    // _queue.cancel();
  }
}
