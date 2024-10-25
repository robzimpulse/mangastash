import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';

class DownloadChapterManager implements DownloadChapterUseCase {
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final BaseCacheManager _cacheManager;

  DownloadChapterManager({
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required BaseCacheManager cacheManager,
  })  : _getChapterUseCase = getChapterUseCase,
        _cacheManager = cacheManager;

  @override
  Future<ValueStream<double>?> downloadChapter({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  }) async {
    final result = await _getChapterUseCase().execute(
      chapterId: chapterId,
      source: source,
      mangaId: mangaId,
    );

    if (result is Success<MangaChapter>) {
      final images = result.data.images ?? [];
      final streams = images.map(
        (e) => _cacheManager.getFileStream(e, withProgress: true),
      );

      // TODO: change to concat eager stream for downloading
      // ConcatEagerStream(streams).listen(
      //   (value) {
      //     if (value is DownloadProgress) {
      //       print(value.progress ?? 0 / length.toDouble());
      //     }
      //   },
      // );

      final stream = CombineLatestStream(
        streams,
        (values) {
          final progress = values.whereType<DownloadProgress>();
          final finish = values.whereType<FileInfo>();
          return progress.fold<double>(
            finish.length / values.length,
            (a, b) => (b.progress ?? 0.0) / values.length,
          );
        },
      );

      return stream.shareValue();
    }

    return null;
  }
}
