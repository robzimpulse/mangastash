import 'dart:async';
import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

class CrawlChapterUseCase {
  final LogBox _logBox;

  final BaseCacheManager _cacheManager;

  CrawlChapterUseCase({
    required LogBox logBox,
    required BaseCacheManager cacheManager,
  })  : _logBox = logBox,
        _cacheManager = cacheManager;

  Future<void> execute({
    MangaChapter? chapter,
  }) async {
    final uri = Uri.tryParse(chapter?.webUrl ?? '');
    if (uri == null) return;

    final String? cached = await _cacheManager
        .getFileFromCache(chapter?.webUrl ?? '')
        .then((file) => file?.file.readAsString());

    await _logBox.navigateToWebview(
      uri: uri,
      html: cached ?? '',
      onTapSnapshot: (value) => _cacheManager.putFile(
        uri.toString(),
        utf8.encode(value ?? ''),
        fileExtension: 'html',
        maxAge: const Duration(minutes: 5),
      ),
    );
  }
}
