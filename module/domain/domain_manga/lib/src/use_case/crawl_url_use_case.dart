import 'dart:async';
import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

class CrawlUrlUseCase {
  final LogBox _logBox;

  final CustomCacheManager _cacheManager;

  CrawlUrlUseCase({
    required LogBox logBox,
    required CustomCacheManager cacheManager,
  }) : _logBox = logBox,
       _cacheManager = cacheManager;

  Future<void> execute({
    required BuildContext context,
    required String url,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final String? cached = await _cacheManager.html
        .getFileFromCache(url)
        .then((file) => file?.file.readAsString());

    if (!context.mounted) return;
    await _logBox.webview(
      context: context,
      uri: uri,
      html: cached,
      onTapSnapshot: (url, html) {
        if (html == null) return;
        _cacheManager.html.putFile(
          url ?? uri.toString(),
          utf8.encode(html),
          fileExtension: 'html',
          maxAge: const Duration(minutes: 30),
        );
      },
    );
  }
}
