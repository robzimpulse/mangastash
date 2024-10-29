import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';

typedef DownloadChapterKey = (
  MangaSourceEnum? source,
  String? mangaId,
  String? chapterId
);

typedef FileResponsesStream = Iterable<Stream<FileResponse>>;

class DownloadChapterManager implements DownloadChapterUseCase {
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final BaseCacheManager _cacheManager;

  final Map<DownloadChapterKey?, BehaviorSubject<double>> _progress = {};

  DownloadChapterManager({
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required BaseCacheManager cacheManager,
  })  : _getChapterUseCase = getChapterUseCase,
        _cacheManager = cacheManager;

  @override
  ValueStream<double> downloadChapterProgressStream({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  }) {
    final DownloadChapterKey key = (source, mangaId, chapterId);

    final progress = _progress[key] ?? BehaviorSubject.seeded(0.0);

    _progress.putIfAbsent(key, () => progress);

    int counter = 0;

    progress.addStream(
      Stream.fromFuture(
        _getChapterUseCase().execute(
          chapterId: chapterId,
          source: source,
          mangaId: mangaId,
        ),
      ).transform(
        StreamTransformer<Result<MangaChapter>,
            FileResponsesStream>.fromHandlers(
          handleData: (value, sink) {
            if (value is Success<MangaChapter>) {
              final images = value.data.images ?? [];
              final streams = images.map(
                (e) => _cacheManager.getFileStream(e, withProgress: true),
              );
              sink.add(streams.toList());
              return;
            }
            sink.add(<Stream<FileResponse>>[]);
          },
        ),
      ).asyncExpand(
        (event) => ConcatEagerStream(event).transform(
          StreamTransformer<FileResponse, double>.fromHandlers(
            handleData: (value, sink) {
              if (value is DownloadProgress) {
                sink.add(
                  ((value.progress ?? 0) + counter) / event.length,
                );
              }

              if (value is FileInfo) {
                counter++;
              }
            },
          ),
        ),
      ),
    );

    return progress.stream;
  }

  @override
  double downloadChapterProgress({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  }) {
    final DownloadChapterKey key = (source, mangaId, chapterId);
    final progress = _progress[key] ?? BehaviorSubject.seeded(0.0);
    _progress.putIfAbsent(key, () => progress);
    return progress.valueOrNull ?? 0.0;
  }
}
