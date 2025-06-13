import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({
    super.key,
    required this.html,
    required this.uri,
    this.onTapSnapshot,
  });

  final String html;

  final Uri uri;

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

  final userAgent = 'Mozilla/5.0 '
      '(Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/127.0.0.0 '
      'Safari/537.36';

  final key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: move this inside block webview
      endDrawer: Drawer(
        child: messages.isEmpty
            ? const Center(child: Text('No messages'))
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: messages.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => Padding(
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
            onPressed: () => webViewController?.loadUrl(
              urlRequest: URLRequest(
                url: WebUri.uri(widget.uri),
              ),
            ),
            icon: const Icon(Icons.refresh),
          ),
          if (widget.onTapSnapshot != null)
            IconButton(
              onPressed: () async => widget.onTapSnapshot?.call(
                (await webViewController?.getUrl()).toString(),
                await webViewController?.getHtml(),
              ),
              icon: const Icon(Icons.camera_alt),
            ),
          Builder(
            builder: (context) => IconButton(
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
          initialData: widget.html.isNotEmpty
              ? InAppWebViewInitialData(
                  baseUrl: WebUri.uri(widget.uri),
                  data: widget.html,
                )
              : null,
          onWebViewCreated: (controller) => webViewController = controller,
          initialSettings: InAppWebViewSettings(
            isInspectable: true,
            javaScriptEnabled: true,
          ),
          onContentSizeChanged: (_, curr, prev) => _log(
            'onContentSizeChanged: $curr - $prev',
          ),
          onLoadStart: (_, url) => _log('onLoadStart: $url'),
          onLoadStop: (_, url) => _log('onLoadStart: $url'),
          onProgressChanged: (_, progress) => _log('onProgress: $progress'),
          onReceivedError: (_, request, error) => _log(
            'onReceivedError: ${request.url} - ${error.description}',
          ),
          onConsoleMessage: (_, message) => _log(
            'onConsoleMessage: ${message.message}',
          ),
          onNavigationResponse: (_, response) async {
            final destination = response.response?.url;

            _log('onNavigationResponse: $destination');

            return NavigationResponseAction.ALLOW;
          },
          shouldOverrideUrlLoading: (_, action) async {
            final destination = action.request.url;

            _log('shouldOverrideUrlLoading: $destination');

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
