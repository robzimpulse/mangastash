import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/download_chapter_progress_use_case.dart';
import '../use_case/chapter/download_chapter_use_case.dart';
import '../use_case/chapter/get_chapter_use_case.dart';
import '../use_case/chapter/listen_active_download_use_case.dart';

class DownloadChapterManager
    implements
        ListenActiveDownloadUseCase,
        DownloadChapterUseCase,
        DownloadChapterProgressUseCase {
  final ValueGetter<Dio> _dio;
  final ValueGetter<GetChapterUseCase> _getChapterUseCase;
  final BaseCacheManager _cacheManager;
  final ListenDownloadPathUseCase _listenDownloadPathUseCase;
  final _active = BehaviorSubject<Set<DownloadChapter>>.seeded({});
  final _progress = <DownloadChapter, BehaviorSubject<(int, double)>>{};

  DownloadChapterManager({
    required ValueGetter<Dio> dio,
    required ValueGetter<GetChapterUseCase> getChapterUseCase,
    required BaseCacheManager cacheManager,
    required ListenDownloadPathUseCase listenDownloadPathUseCase,
  })  : _cacheManager = cacheManager,
        _dio = dio,
        _getChapterUseCase = getChapterUseCase,
        _listenDownloadPathUseCase = listenDownloadPathUseCase {

    _active.map((event) => event.firstOrNull).distinct().listen(_startDownload);
  }

  @override
  ValueStream<(int, double)> downloadChapterProgressStream({
    required DownloadChapter key,
  }) {
    final progress = _progress[key] ?? BehaviorSubject.seeded((0, 0.0));
    _progress.putIfAbsent(key, () => progress);
    return progress.stream;
  }

  @override
  Future<void> downloadChapter({
    required DownloadChapter key,
  }) async {
    final progress = _progress[key] ?? BehaviorSubject.seeded((0, 0.0));
    _progress.putIfAbsent(key, () => progress);
    if (_active.valueOrNull?.contains(key) == true) return;
    _active.add((_active.valueOrNull ?? {})..add(key));
    log(
      'Adding ${key.hashCode} to active download',
      name: runtimeType.toString(),
      time: DateTime.now(),
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

  void _startDownload(DownloadChapter? key) async {
    if (key == null) return;

    final isPermissionGranted = await Future.wait([
      Permission.storage.isGranted,
      Permission.manageExternalStorage.isGranted,
    ]);

    if (!isPermissionGranted.any((e) => e)) {
      _active.add((_active.valueOrNull ?? {})..remove(key));

      log(
        'Removing ${key.hashCode} from active download',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      return;
    }

    final result = await _getChapterUseCase().execute(
      chapterId: key.chapter?.id,
      source: key.manga?.source,
      mangaId: key.manga?.id,
    );

    if (result is Success<MangaChapter>) {
      log(
        'Success fetching chapter images for ${key.hashCode}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );

      final images = result.data.images ?? [];
      final root = _listenDownloadPathUseCase.downloadPathStream.valueOrNull;
      final title = key.manga?.title;
      final chapter = key.chapter?.numChapter;

      for (final (index, url) in images.indexed) {
        final ext = url.split('.').lastOrNull;

        if (root == null || title == null || chapter == null || ext == null) {
          continue;
        }

        final newPath = '${root.path}/$title/$chapter/${index + 1}.$ext';

        try {
          log(
            'Start download chapter image $url',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );

          await _dio().download(url, newPath);

          _progress[key]?.add((index, index / (images.length - 1)));

          log(
            'Finish download chapter image $url',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );

          log(
            'Start registering cache chapter image for $url',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );

          await _cacheManager.putFile(url, File(newPath).readAsBytesSync());

          log(
            'Finish registering cache chapter image for $url',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );
        } catch (e) {
          log(
            'Failed download chapter image for $url | $e',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );
        }
      }
    }

    if (result is Error<MangaChapter>) {
      log(
        'Failed fetching chapter images for ${key.hashCode} | ${result.error}',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }

    _active.add((_active.valueOrNull ?? {})..remove(key));

    log(
      'Removing ${key.hashCode} from active download',
      name: runtimeType.toString(),
      time: DateTime.now(),
    );
  }
}
