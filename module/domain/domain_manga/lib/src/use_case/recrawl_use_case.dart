import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';

class RecrawlUseCase {
  final LogBox _logBox;
  final HtmlCacheManager _htmlCacheManager;

  RecrawlUseCase({
    required LogBox logBox,
    required HtmlCacheManager htmlCacheManager,
  }) : _htmlCacheManager = htmlCacheManager,
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

        _logBox.log(
          name: runtimeType.toString(),
          'Finish caching html for url [$uri]',
        );
      },
    );
  }
}
