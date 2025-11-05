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

  final Map<(String, List<String>, bool), Future<Document?>> _cDocument = {};
  final Map<(String, Map<String, String>?, bool), Future<String>> _cImage = {};

  HeadlessWebviewManager({
    required LogBox log,
    required HtmlCacheManager htmlCacheManager,
  }) : _log = log,
       _htmlCacheManager = htmlCacheManager;

  @override
  Future<Document?> open(
    String url, {
    List<String> scripts = const [],
    bool useCache = true,
  }) {
    return _cDocument.putIfAbsent(
      (url, scripts, useCache),
      () => _open(
        url,
        scripts: scripts,
        useCache: useCache,
      ).whenComplete(() => _cDocument.remove((url, scripts, useCache))),
    );
  }

  @override
  Future<String> image(
    String url, {
    bool useCache = true,
    Map<String, String>? headers,
  }) {
    return _cImage.putIfAbsent(
      (url, headers, useCache),
      () => _image(
        url,
        headers: headers,
        useCache: useCache,
      ).whenComplete(() => _cImage.remove((url, headers, useCache))),
    );
  }

  Future<Document?> _open(
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

  Future<String> _image(
    String url, {
    bool useCache = true,
    Map<String, String>? headers,
  }) async {
    final Completer<String> completer = Completer();

    final stringHeaders =
        headers == null ? '' : ', {headers: ${headers.toString()}}';

    await _fetch(
      uri: WebUri(url),
      delegate: _log.inAppWebviewObserver,
      useCache: useCache,
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
        'resolved': (args) {
          if (args.isEmpty) return;
          final data = args.first;
          if (data is! String) {
            _log.log(
              'Failed to download image [$url]',
              name: runtimeType.toString(),
            );
            return;
          }

          _log.log(
            'Success to download image [$url]',
            name: runtimeType.toString(),
            extra: {'url': url, 'data': data},
          );

          completer.safeComplete(data);
        },
        'reject': (args) {
          _log.log(
            'Failed to download image [$url]',
            name: runtimeType.toString(),
            extra: {'url': url, 'error': args.toString()},
          );
          completer.completeError(args);
        },
      },
      signalComplete: completer.future,
    );

    return completer.future;
  }

  Future<String?> _fetch({
    required WebUri uri,
    required InAppWebviewObserver delegate,
    UnmodifiableListView<UserScript>? initialUserScripts,
    Map<String, JavaScriptHandlerCallback>? javascriptHandlers,
    List<String> scripts = const [],
    bool useCache = true,
    Future<void>? signalComplete,
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

    if (signalComplete != null) {
      await signalComplete.timeout(const Duration(seconds: 10));
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
