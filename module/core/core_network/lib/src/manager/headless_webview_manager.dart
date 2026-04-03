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
import '../mixin/user_agent_mixin.dart';
import '../usecase/headless_webview_use_case.dart';

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

class HeadlessWebviewManager implements HeadlessWebviewUseCase {
  final LogBox _log;
  final HtmlCacheManager _htmlCacheManager;

  final Map<_Key, Future<Document>> _cDocument = {};
  final Map<_Key, Future<String>> _cImage = {};
  final Map<int, HeadlessInAppWebView> _instances = {};

  final _imgExt = ['jpeg', 'jpg', 'gif', 'webp', 'png', 'ico', 'bmp', 'wbmp'];

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
    bool useCache = true,
    Duration? timeout,
  }) async {
    return parse(
      await _fetch(
        uri: WebUri(url),
        scripts: scripts,
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
        'resolved': (args) {
          if (args.isEmpty) return;
          final data = args.first;
          if (data is! String) {
            _log.log(
              'Failed to download image [$url]',
              extra: {'url': url, 'args': args},
              name: runtimeType.toString(),
            );
            return;
          }

          final values = data.split(RegExp(r'[:;,]+'));
          final ext = values[1].split('/').lastOrNull;

          if (_imgExt.contains(ext)) {
            _log.log(
              'Success download image [$url]',
              name: runtimeType.toString(),
              extra: {'url': url, 'data': data},
            );
            completer.safeComplete(data);
          } else {
            _log.log(
              'Failed download image [$url]',
              name: runtimeType.toString(),
              error: Exception('Image format $ext not supported'),
              extra: {'url': url, 'args': args},
            );
            completer.safeCompleteError(
              Exception('Image format $ext not supported'),
            );
          }
        },
        'reject': (args) {
          _log.log(
            'Failed to download image [$url]',
            name: runtimeType.toString(),
            extra: {'url': url, 'error': args.toString()},
          );
          completer.safeCompleteError(Exception('Error fetch image'));
        },
      },
      signalComplete: completer.future,
    );

    return completer.future;
  }

  Future<String> _fetch({
    required WebUri uri,
    required InAppWebviewObserver delegate,
    UnmodifiableListView<UserScript>? initialUserScripts,
    Map<String, JavaScriptHandlerCallback>? javascriptHandlers,
    List<String> scripts = const [],
    bool useCache = true,
    Future? signalComplete,
    Duration? timeout,
  }) async {
    delegate.set(uri: uri, loading: true);
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

    _instances[webview.hashCode] = webview;

    try {
      if (timeout != null) {
        await Future.wait([
          webview.run(),
          onLoadStartCompleter.future,
          Future.any([onLoadStopCompleter.future, onLoadErrorCompleter.future]),
        ]).timeout(const Duration(seconds: 15));
      } else {
        await Future.wait([
          webview.run(),
          onLoadStartCompleter.future,
          Future.any([onLoadStopCompleter.future, onLoadErrorCompleter.future]),
        ]);
      }
    } catch (e, st) {
      delegate.set(error: e, stackTrace: st, loading: false);
      _instances.remove(webview.hashCode);
      await webview.dispose();
      rethrow;
    }

    for (final script in scripts) {
      if (script.isEmpty) continue;
      await Future.delayed(const Duration(seconds: 1));
      await webview.webViewController?.evaluateJavascript(source: script);
      delegate.onRunJavascript(script: script);
    }

    if (signalComplete != null) {
      if (timeout != null) {
        try {
          await signalComplete.timeout(const Duration(seconds: 15));
        } catch (e, st) {
          delegate.set(error: e, stackTrace: st, loading: false);
          _instances.remove(webview.hashCode);
          await webview.dispose();
          rethrow;
        }
      } else {
        await signalComplete;
      }
    }

    final html = await webview.webViewController?.getHtml();

    final title = await webview.webViewController?.getTitle();

    await webview.dispose();

    _instances.remove(webview.hashCode);

    if (html == null) {
      delegate.set(error: Exception('Null Html'), loading: false);
      throw FailedParsingHtmlException(uri.toString());
    }

    if (title == 'Just a moment...') {
      delegate.set(error: Exception('Cloudflare Challenge'), loading: false);
      throw FailedParsingHtmlException(uri.toString());
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
