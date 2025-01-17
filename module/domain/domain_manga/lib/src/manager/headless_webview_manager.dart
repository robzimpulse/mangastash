import 'dart:async';
import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:log_box/log_box.dart';

class HeadlessWebviewManager {
  final LogBox _log;
  final HeadlessInAppWebView _webview;
  final BaseCacheManager _cacheManager;

  final Map<Uri, Future<String?>> _queue = {};

  InAppWebViewController get _controller => _webview.webViewController;

  static Future<HeadlessWebviewManager> create({
    required LogBox log,
    required BaseCacheManager cacheManager,
  }) async {
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse('https://google.com')),
      onWebViewCreated: (controller) {
        log.log(
          'onWebViewCreated',
          name: 'HeadlessWebviewManager',
        );
      },
    );

    await webview.run();

    return HeadlessWebviewManager(
      log: log,
      webview: webview,
      cacheManager: cacheManager,
    );
  }

  HeadlessWebviewManager({
    required LogBox log,
    required HeadlessInAppWebView webview,
    required BaseCacheManager cacheManager,
  })  : _log = log,
        _webview = webview,
        _cacheManager = cacheManager;

  Future<Document?> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _log.log('Error parsing url: $url', name: runtimeType.toString());
      return null;
    }
    final html = await _queue.putIfAbsent(uri, () => _fetch(uri: uri));
    if (html == null) return null;
    return parse(html);
  }

  Future<String?> _fetch({required Uri uri}) async {
    final cache = await _cacheManager.getFileFromCache(uri.toString());
    if (cache != null) {
      return await cache.file.readAsString();
    }

    await _controller.loadUrl(urlRequest: URLRequest(url: uri));
    final onLoadStartCompleter = Completer();
    final onLoadStopCompleter = Completer();
    final onLoadErrorCompleter = Completer();

    _webview.onLoadStart = (controller, url) async {
      _log.log(
        'onLoadStart: $url',
        name: 'HeadlessWebviewManager',
      );
      onLoadStartCompleter.complete();
    };

    _webview.onLoadStop = (controller, url) async {
      _log.log(
        'onLoadStop: $url',
        name: 'HeadlessWebviewManager',
      );
      onLoadStopCompleter.complete();
    };

    _webview.onLoadError = (controller, url, code, message) async {
      _log.log(
        'onLoadError: $url - $code - $message',
        name: 'HeadlessWebviewManager',
      );
      onLoadErrorCompleter.complete();
    };

    await Future.wait(
      [
        onLoadStartCompleter.future,
        Future.any(
          [
            onLoadStopCompleter.future,
            onLoadErrorCompleter.future,
          ],
        ),
      ],
    );

    final html = await _controller.getHtml();
    if (html == null) return null;

    await _cacheManager.putFile(
      uri.toString(),
      utf8.encode(html),
      fileExtension: 'html',
      maxAge: const Duration(minutes: 5),
    );

    return html;
  }

  Future<void> dispose() => _webview.dispose();
}
