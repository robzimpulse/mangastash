import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({super.key, required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final html = this.html;

    final ValueNotifier<List<String>> messages = ValueNotifier([]);

    final delegate = NavigationDelegate(
      onNavigationRequest: (request) {
        messages.value = [
          ...messages.value,
          'onNavigationRequest: ${request.url}',
        ];
        return NavigationDecision.navigate;
      },
      onPageStarted: (request) {
        messages.value = [
          ...messages.value,
          'onPageStarted: $request',
        ];
      },
      onHttpAuthRequest: (request) {
        messages.value = [
          ...messages.value,
          'onHttpAuthRequest: ${request.host}',
        ];
      },
      onHttpError: (request) {
        messages.value = [
          ...messages.value,
          'onHttpError: ${request.response?.uri} - ${request.response?.statusCode}',
        ];
      },
      onPageFinished: (request) {
        messages.value = [
          ...messages.value,
          'onPageFinished: $request',
        ];
      },
      onProgress: (request) {
        messages.value = [
          ...messages.value,
          'onProgress: $request',
        ];
      },
      onUrlChange: (request) {
        messages.value = [
          ...messages.value,
          'onUrlChange: ${request.url}',
        ];
      },
      onWebResourceError: (request) {
        messages.value = [
          ...messages.value,
          'onWebResourceError: ${request.url} - ${request.errorType} - ${request.errorCode}',
        ];
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Preview'),
        elevation: 3,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(delegate)
                ..loadHtmlString(html),
            ),
          ),
          Flexible(
            flex: 1,
            child: ValueListenableBuilder(
              valueListenable: messages,
              builder: (context, values, _) => ListView.separated(
                itemCount: values.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(values[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
