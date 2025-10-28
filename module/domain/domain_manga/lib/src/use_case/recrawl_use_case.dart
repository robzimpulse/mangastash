import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';

class RecrawlUseCase {
  final LogBox _logBox;
  final CookieJar _cookieJar;
  final HtmlCacheManager _htmlCacheManager;

  RecrawlUseCase({
    required LogBox logBox,
    required CookieJar cookieJar,
    required HtmlCacheManager htmlCacheManager,
  }) : _htmlCacheManager = htmlCacheManager,
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
      onTapSnapshot: (url, html) async {
        if (url == null || html == null) return;

        await _htmlCacheManager.putFile(
          url,
          utf8.encode(html),
          fileExtension: 'html',
          maxAge: const Duration(minutes: 30),
        );

        final cookies = await CookieManager.instance().getAllCookies();
        await _cookieJar.saveFromResponse(uri, [
          ...cookies.map((e) => Cookie(e.name, e.value)),
        ]);

        _logBox.log(
          name: runtimeType.toString(),
          'Finish caching html and sync cookies',
          extra: {
            'url': uri.toString(),
            'cookies': [...cookies.map((e) => e.toJson())],
          },
        );
      },
    );
  }
}
