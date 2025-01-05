import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:log_box/log_box.dart';

class HeadlessWebviewManager {
  final LogBox _log;
  final HeadlessInAppWebView _webview;

  InAppWebViewController get _controller => _webview.webViewController;

  static Future<HeadlessWebviewManager> create({
    required LogBox log,
  }) async {
    final webview = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse('https://google.com')),
      onWebViewCreated: (controller) {
        log.log(
          'onWebViewCreated',
          name: 'HeadlessWebviewManager',
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        log.log(
          'onConsoleMessage: ${consoleMessage.message}',
          name: 'HeadlessWebviewManager',
        );
      },
      onLoadStart: (controller, url) async {
        log.log(
          'onLoadStart: $url',
          name: 'HeadlessWebviewManager',
        );
      },
      onLoadStop: (controller, url) async {
        log.log(
          'onLoadStop: $url - [${controller.getHtml()}]',
          name: 'HeadlessWebviewManager',
        );
      },
      onLoadError: (controller, url, code, message) async {
        log.log(
          'onLoadError: $url - $code - $message',
          name: 'HeadlessWebviewManager',
        );
      },
    );

    await webview.run();

    return HeadlessWebviewManager(log: log, webview: webview);
  }

  HeadlessWebviewManager({
    required LogBox log,
    required HeadlessInAppWebView webview,
  })  : _log = log,
        _webview = webview;

  Future<Document?> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _log.log('Error parsing url: $url', name: runtimeType.toString());
      return null;
    }
    final request = URLRequest(url: uri);
    await _controller.loadUrl(urlRequest: request);
    final html = await _controller.getHtml();
    if (html == null) return null;
    return parse(html);
  }

  Future<void> dispose() => _webview.dispose();
}
