import 'dart:async';
import 'dart:convert';

import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:log_box/log_box.dart';
import 'package:queue/queue.dart';

class HeadlessWebviewManager {
  final LogBox _log;
  final BaseCacheManager _cacheManager;

  final _queue = Queue(delay: const Duration(milliseconds: 200));

  HeadlessWebviewManager({
    required LogBox log,
    required BaseCacheManager cacheManager,
  })  : _log = log,
        _cacheManager = cacheManager;

  Future<Document?> open(String url) async {
    final uri = WebUri(url);
    final html = await _queue.add(() => _fetch(uri: uri));
    if (html == null) return null;
    _log.logHtml(uri, html, name: 'HeadlessWebviewManager');
    return parse(html);
  }

  Future<String?> _fetch({required WebUri uri}) async {
    final cache = await _cacheManager.getFileFromCache(uri.toString());
    if (cache != null) return await cache.file.readAsString();

    final onLoadStartCompleter = Completer();
    final onLoadStopCompleter = Completer();
    final onLoadErrorCompleter = Completer();

    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: uri),
      onLoadStart: (controller, url) => onLoadStartCompleter.safeComplete(),
      onLoadStop: (controller, url) => onLoadStopCompleter.safeComplete(),
      onReceivedError: (controller, request, error) {
        onLoadErrorCompleter.safeComplete();
      },
    );

    await Future.wait(
      [
        webview.run(),
        onLoadStartCompleter.future,
        Future.any(
          [
            onLoadStopCompleter.future,
            onLoadErrorCompleter.future,
          ],
        ),
      ],
    );

    final html = await webview.webViewController?.getHtml();
    await webview.dispose();
    if (html == null) return null;

    await _cacheManager.putFile(
      uri.toString(),
      utf8.encode(html),
      fileExtension: 'html',
      maxAge: const Duration(minutes: 30),
    );

    return html;
  }

  Future<void> dispose() async {
    _queue.cancel();
  }
}
