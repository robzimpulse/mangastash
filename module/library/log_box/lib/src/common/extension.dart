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

extension JsonExtension on String? {
  String get prettify {
    if (this != null) {
      try {
        var decoded = json.decode(this!);
        var encoder = const JsonEncoder.withIndent('  ');
        var prettyJson = encoder.convert(decoded);
        return prettyJson;
      } catch (e) {
        return 'N/A-Cannot Parse';
      }
    }
    return 'N/A';
  }

  bool get isJson {
    try {
      json.decode(this!);
      return true;
    } catch (_) {
      return false;
    }
  }

  String toJson() {
    return json.encode(this);
  }

  Map<String, dynamic> toMap() {
    if (this == null) {
      return <String, dynamic>{};
    }
    return json.decode(this!);
  }
}
