import 'dart:async';
import 'dart:developer';

import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/download_chapter_progress_use_case.dart';
import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/listen_active_download_use_case.dart';

typedef _FileStream = Iterable<Stream<FileResponse>>;

class DownloadChapterManager
    implements
        ListenActiveDownloadUseCase,
        DownloadChapterUseCase,
        DownloadChapterProgressUseCase {
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final BaseCacheManager _cacheManager;

  final _active = BehaviorSubject<Set<DownloadChapter>>.seeded({});

  final _progress = <DownloadChapter, BehaviorSubject<(int, double)>>{};

  DownloadChapterManager({
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required BaseCacheManager cacheManager,
  })  : _cacheManager = cacheManager,
        _getChapterUseCase = getChapterUseCase;

  @override
  ValueStream<(int, double)> downloadChapterProgressStream({
    required DownloadChapter key,
  }) {
    final progress = _progress[key] ?? BehaviorSubject.seeded((0, 0.0));
    _progress.putIfAbsent(key, () => progress);
    return progress.stream;
  }

  @override
  void downloadChapter({
    required DownloadChapter key,
  }) {
    final progress = _progress[key] ?? BehaviorSubject.seeded((0, 0.0));
    _progress.putIfAbsent(key, () => progress);

    _active.add((_active.valueOrNull ?? {})..add(key));
    log(
      'Adding ${key.hashCode} to active download',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );

    final stream = Stream.fromFuture(
      _getChapterUseCase().execute(
        chapterId: key.chapter?.id,
        source: key.manga?.source,
        mangaId: key.manga?.id,
      ),
    ).transform(
      StreamTransformer<Result<MangaChapter>, _FileStream>.fromHandlers(
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
      (event) {
        int counter = 0;
        return ConcatEagerStream(event).transform(
          StreamTransformer<FileResponse, (int, double)>.fromHandlers(
            handleData: (value, sink) {
              if (value is DownloadProgress) {
                sink.add(
                  (counter, ((value.progress ?? 0) + counter) / event.length),
                );
              }

              if (value is FileInfo) {
                counter++;
                sink.add((counter, counter / event.length));
              }
            },
          ),
        ).doOnDone(() {
          _active.add((_active.valueOrNull ?? {})..remove(key));
          log(
            'Removing ${key.hashCode} from active download',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );
        });
      },
    );

    progress.listen(
      (value) => log(
        'progress: $value for key ${key.hashCode}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      ),
    );

    progress.addStream(
      stream.throttleTime(const Duration(milliseconds: 500), trailing: true),
    );
  }

  @override
  double downloadChapterProgress({
    required DownloadChapter key,
  }) {
    final progress = _progress[key] ?? BehaviorSubject.seeded((0, 0.0));
    _progress.putIfAbsent(key, () => progress);
    return progress.valueOrNull?.$2 ?? 0.0;
  }

  @override
  ValueStream<Set<DownloadChapter>> get activeDownloadStream => _active.stream;
}
