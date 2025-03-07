import 'dart:async';
import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:log_box/log_box.dart';

class CrawlUrlUseCase {
  final LogBox _logBox;

  final BaseCacheManager _cacheManager;

  CrawlUrlUseCase({
    required LogBox logBox,
    required BaseCacheManager cacheManager,
  })  : _logBox = logBox,
        _cacheManager = cacheManager;

  Future<void> execute({
    required String url,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final String? cached = await _cacheManager
        .getFileFromCache(url)
        .then((file) => file?.file.readAsString());

    await _logBox.navigateToWebview(
      uri: uri,
      html: cached ?? '',
      onTapSnapshot: (url, html) => _cacheManager.putFile(
        url ?? uri.toString(),
        utf8.encode(html ?? ''),
        fileExtension: 'html',
        maxAge: const Duration(minutes: 5),
      ),
    );
  }
}
