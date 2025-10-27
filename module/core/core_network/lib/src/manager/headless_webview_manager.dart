import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:universal_io/io.dart';

import '../mixin/user_agent_mixin.dart';
import '../usecase/headless_webview_usecase.dart';

class HeadlessWebviewManager implements HeadlessWebviewUseCase {
  final LogBox _log;

  final HtmlCacheManager _htmlCacheManager;
  final ImageCacheManager _imageCacheManager;

  HeadlessWebviewManager({
    required LogBox log,
    required HtmlCacheManager htmlCacheManager,
    required ImageCacheManager imageCacheManager,
  }) : _log = log,
       _htmlCacheManager = htmlCacheManager,
       _imageCacheManager = imageCacheManager;

  @override
  Future<Document?> open(
    String url, {
    List<String> scripts = const [],
    bool useCache = true,
  }) async {
    final uri = WebUri(url);
    final html = await _fetch(
      uri: uri,
      scripts: scripts,
      delegate: _log.inAppWebviewObserver,
      useCache: useCache,
    );
    if (html == null) return null;
    return parse(html, sourceUrl: url);
  }

  Future<void> image(String url, {bool useCache = true}) async {
    await _fetch(
      uri: WebUri(url),
      delegate: _log.inAppWebviewObserver,
      useCache: useCache,
      initialUserScripts: UnmodifiableListView([
        UserScript(
          source: '''
            const toDataURL = url => fetch(url)
              .then(response => response.blob())
              .then(blob => new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onloadend = () => resolve(reader.result);
                reader.onerror = reject;
                reader.readAsDataURL(blob);
              }));
          ''',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
        ),
      ]),
      scripts: [
        '''
        toDataURL('$url')
          .then(e => window.flutter_inappwebview.callHandler('ch', e));
        ''',
      ],
      javascriptHandlers: {
        'ch': (args) async {
          final ext = url.split('.').lastOrNull;
          final String? base64 = args[0].castOrNull();
          if (base64 == null || ext == null) {
            _log.log(
              'Failed to download image [$url]',
              name: runtimeType.toString(),
              extra: {'data': base64, 'extension': ext},
            );

            return;
          }

          await _imageCacheManager.putFile(
            url,
            base64Decode(base64),
            fileExtension: ext,
          );
        },
      },
    );
  }

  Future<String?> _fetch({
    required WebUri uri,
    required InAppWebviewObserver delegate,
    UnmodifiableListView<UserScript>? initialUserScripts,
    Map<String, JavaScriptHandlerCallback>? javascriptHandlers,
    List<String> scripts = const [],
    bool useCache = true,
  }) async {
    final key = [uri.toString(), ...scripts].join('|');
    final cache = await _htmlCacheManager.getFileFromCache(key);
    final data = await cache?.file.readAsString(encoding: utf8);
    if (data != null && useCache) {
      delegate.set(uri: uri, html: data, loading: false);
      return data;
    }

    final onLoadStartCompleter = Completer();
    final onLoadStopCompleter = Completer();
    final onLoadErrorCompleter = Completer();

    final webview = HeadlessInAppWebView(
      initialUserScripts: initialUserScripts,
      initialUrlRequest: URLRequest(
        url: uri,
        headers: {HttpHeaders.userAgentHeader: UserAgentMixin.staticUserAgent},
      ),
      initialSettings: InAppWebViewSettings(
        isInspectable: true,
        javaScriptEnabled: true,
        supportZoom: false,
      ),
      onWebViewCreated: (controller) {
        delegate.onWebViewCreated(uri: uri, scripts: scripts);
        final handlers = javascriptHandlers?.entries ?? [];
        if (handlers.isEmpty) return;
        for (final handler in handlers) {
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

    await _htmlCacheManager.putFile(
      uri.toString(),
      utf8.encode(html),
      fileExtension: 'html',
      maxAge: const Duration(minutes: 30),
    );

    delegate.set(html: html, loading: false);
    return html;
  }
}
