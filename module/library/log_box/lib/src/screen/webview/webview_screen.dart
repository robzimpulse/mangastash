import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:universal_io/io.dart';

import '../../common/webview_delegate.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({
    super.key,
    required this.html,
    required this.uri,
    required this.delegate,
    this.scripts = const [],
    this.onTapSnapshot,
  });

  final WebviewDelegate delegate;

  final String html;

  final Uri uri;

  final List<String> scripts;

  final Function(String? url, String? html)? onTapSnapshot;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;

  final List<String> messages = [];

  void _log(String message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  final userAgent =
      'Mozilla/5.0 '
      '(Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/127.0.0.0 '
      'Safari/537.36';

  final key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child:
            messages.isEmpty
                ? const Center(child: Text('No messages'))
                : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(messages[index]),
                      ),
                ),
      ),
      appBar: AppBar(
        title: const Text('Web Preview'),
        elevation: 3,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final controller = TextEditingController();

              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Run JavaScript'),
                    content: TextField(controller: controller),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );

              final script = controller.text;

              controller.dispose();

              if (script.isEmpty) return;

              webViewController?.evaluateJavascript(source: script);
            },
            icon: const Icon(Icons.javascript),
          ),
          IconButton(
            onPressed: () {
              webViewController?.loadUrl(
                urlRequest: URLRequest(url: WebUri.uri(widget.uri)),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
          if (widget.onTapSnapshot != null)
            IconButton(
              onPressed: () async {
                widget.onTapSnapshot?.call(
                  (await webViewController?.getUrl()).toString(),
                  await webViewController?.getHtml(),
                );
              },
              icon: const Icon(Icons.camera_alt),
            ),
          Builder(
            builder:
                (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.code),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: InAppWebView(
          key: key,
          initialUrlRequest: URLRequest(
            url: WebUri.uri(widget.uri),
            headers: {HttpHeaders.userAgentHeader: userAgent},
          ),
          initialData:
              widget.html.isNotEmpty
                  ? InAppWebViewInitialData(
                    baseUrl: WebUri.uri(widget.uri),
                    data: widget.html,
                  )
                  : null,
          onWebViewCreated: (controller) {
            webViewController = controller;
            widget.delegate.onWebViewCreated(uri: widget.uri);
          },
          initialSettings: InAppWebViewSettings(
            isInspectable: true,
            javaScriptEnabled: true,
            supportZoom: false,
          ),
          onContentSizeChanged: (_, curr, prev) {
            _log('onContentSizeChanged: $curr - $prev');
            widget.delegate.onContentSizeChanged(previous: prev, current: curr);
          },
          onLoadStart: (_, url) {
            _log('onLoadStart: $url');
            widget.delegate.onLoadStart(uri: url?.uriValue);
          },
          onLoadStop: (_, url) async {
            _log('onLoadStop: $url');
            widget.delegate.onLoadStop(uri: url?.uriValue);
          },
          onAjaxProgress: (_, request) async {
            widget.delegate.onAjaxRequest(extra: request.toMap());
            return AjaxRequestAction.PROCEED;
          },
          onAjaxReadyStateChange: (_, request) async {
            widget.delegate.onAjaxRequest(extra: request.toMap());
            return null;
          },
          onProgressChanged: (controller, progress) async {
            _log('onProgress: $progress');
            widget.delegate.onProgressChanged(progress: progress);
          },
          onReceivedError: (_, request, error) {
            _log('onReceivedError: ${request.url} - ${error.description}');
            widget.delegate.onReceivedError(
              message: error.description,
              extra: {'request': request.toMap(), 'error': error.toMap()},
            );
          },
          onConsoleMessage: (controller, message) async {
            _log('onConsoleMessage: ${message.message}');
            widget.delegate.onConsoleMessage(extra: message.toMap());
          },
          shouldOverrideUrlLoading: (_, action) async {
            final destination = action.request.url;
            _log('shouldOverrideUrlLoading: $destination');
            widget.delegate.shouldOverrideUrlLoading(extra: action.toMap());

            if (destination == null) {
              return NavigationActionPolicy.CANCEL;
            }

            final isSame = [
              destination.scheme == widget.uri.scheme,
              destination.host == widget.uri.host,
            ].every((e) => e);

            return isSame
                ? NavigationActionPolicy.ALLOW
                : NavigationActionPolicy.CANCEL;
          },
        ),
      ),
    );
  }
}
