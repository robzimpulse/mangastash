import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

extension WebviewControllerExtension on WebViewController {
  Future<String?> getHtml() {
    return runJavaScriptReturningResult(
      'document.documentElement.outerHTML',
    ).then(
      (value) {

        if (value is! String) {
          return null;
        }

        if (platform is AndroidWebViewController) {
          final decoded = jsonDecode(value);
          return decoded is String ? decoded : null;
        }

        return value;
      },
    );
  }
}
