import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/extension.dart';

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({
    super.key,
    required this.html,
    required this.uri,
    this.onTapSnapshot,
  });

  final String html;

  final Uri uri;

  final ValueSetter<String?>? onTapSnapshot;

  @override
  Widget build(BuildContext context) {
    final html = this.html;

    final ValueNotifier<List<String>> messages = ValueNotifier([]);

    final delegate = NavigationDelegate(
      onNavigationRequest: (request) {
        messages.value = [
          'onNavigationRequest: ${request.url}',
          ...messages.value,
        ];
        return NavigationDecision.navigate;
      },
      onPageStarted: (request) {
        messages.value = [
          'onPageStarted: $request',
          ...messages.value,
        ];
      },
      onHttpAuthRequest: (request) {
        messages.value = [
          'onHttpAuthRequest: ${request.host}',
          ...messages.value,
        ];
      },
      onHttpError: (request) {
        messages.value = [
          'onHttpError: ${request.response?.uri} - ${request.response?.statusCode}',
          ...messages.value,
        ];
      },
      onPageFinished: (request) {
        messages.value = [
          'onPageFinished: $request',
          ...messages.value,
        ];
      },
      onProgress: (request) {
        messages.value = [
          'onProgress: $request',
          ...messages.value,
        ];
      },
      onUrlChange: (request) {
        messages.value = [
          'onUrlChange: ${request.url}',
          ...messages.value,
        ];
      },
      onWebResourceError: (request) {
        messages.value = [
          'onWebResourceError: ${request.url} - ${request.errorType} - ${request.errorCode}',
          ...messages.value,
        ];
      },
    );

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(delegate)
      ..setOnConsoleMessage(
        (message) => messages.value = [
          'onJavascriptMessage: ${message.message} - ${message.level}',
          ...messages.value,
        ],
      )
      ..loadHtmlString(html, baseUrl: '${uri.scheme}://${uri.host}');

    return Scaffold(
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
              await controller.loadRequest(uri);
              messages.value = [
                'Refresh: $uri',
                ...messages.value,
              ];
            },
            icon: const Icon(Icons.refresh),
          ),
          if (onTapSnapshot != null)
            IconButton(
              onPressed: () async {
                final html = await controller.getHtml();

                messages.value = [
                  'Snapshot: $html',
                  ...messages.value,
                ];

                onTapSnapshot?.call(html);
              },
              icon: const Icon(Icons.camera_alt),
            ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            child: WebViewWidget(controller: controller),
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
