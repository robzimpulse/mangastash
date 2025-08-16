import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

class RecrawlUseCase {
  final LogBox _logBox;

  final StorageManager _storageManager;

  RecrawlUseCase({
    required LogBox logBox,
    required StorageManager storageManager,
  }) : _storageManager = storageManager,
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
  }
}
