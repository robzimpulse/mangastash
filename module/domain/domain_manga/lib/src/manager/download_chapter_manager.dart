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
      final length = streams.length;
      final transformer = StreamTransformer<FileResponse, double>.fromHandlers(
        handleData: (value, sink) {
          if (value is DownloadProgress) {
            final index = images.indexOf(value.originalUrl);
            final progress = value.progress ?? 0.0;
            sink.add((index.toDouble() + progress) / length);
          }
        },
      );

      return ConcatEagerStream(streams).transform(transformer).shareValue();
    }

    return null;
  }
}
