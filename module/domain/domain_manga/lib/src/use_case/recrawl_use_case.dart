import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show CookieManager;

class RecrawlUseCase {
  final LogBox _logBox;
  final CookieJar _cookieJar;
  final StorageManager _storageManager;

  RecrawlUseCase({
    required LogBox logBox,
    required CookieJar cookieJar,
    required StorageManager storageManager,
  }) : _storageManager = storageManager,
       _cookieJar = cookieJar,
       _logBox = logBox;

  Future<void> execute({
    required BuildContext context,
    required String url,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await _logBox.webview(
      context: context,
      uri: uri,
      onTapSnapshot: (url, html) {
        if (url == null || html == null) return;
        _storageManager.html.putFile(
          url,
          utf8.encode(html),
          fileExtension: 'html',
          maxAge: const Duration(minutes: 30),
        );
      },
    );
    final cookies = (await CookieManager.instance().getAllCookies()).map(
      (e) => Cookie(e.name, e.value),
    );
    await _cookieJar.saveFromResponse(uri, cookies.toList());
  }
}
