import 'dart:async';

import 'package:core_analytics/core_analytics.dart';
import 'package:file/file.dart' show File;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../custom_cache_manager/custom_cache_manager.dart';
import 'file_service/custom_file_service.dart';

class ImagesCacheManager extends CustomCacheManager with ImageCacheManager {
  final FileDao _fileDao;
  final LogBox _logbox;

  /// [fileSystem] overrides where cached files live, and [repo] overrides
  /// where cache metadata is stored. Injecting them in tests avoids
  /// flutter_cache_manager's defaults — [IOFileSystem]'s constructor and
  /// [CustomCacheStore]'s eager `repo.open()` both hit platform channels
  /// unavailable in unit tests. [fileSystem] is also the seam for a
  /// persistent web file system (see CLAUDE.md: image-cache persistence on
  /// web).
  ImagesCacheManager({
    required CustomFileService fileService,
    required FileDao fileDao,
    required LogBox logBox,
    FileSystem? fileSystem,
    CacheInfoRepository? repo,
  }) : this._(
         config: _buildConfig(
           fileService: fileService,
           fileSystem: fileSystem,
           repo: repo,
         ),
         fileDao: fileDao,
         logBox: logBox,
       );

  ImagesCacheManager._({
    required Config config,
    required FileDao fileDao,
    required LogBox logBox,
  }) : _fileDao = fileDao,
       _logbox = logBox,
       super(
         config,
         rescueEvictedFile: (object, file) async {
           await fileDao.addFromFile(webUrl: object.url, file: file);
         },
       );

  /// Config's named params are non-nullable in its factory signature, so a
  /// nullable override must be forwarded by omission, not by passing null.
  static Config _buildConfig({
    required CustomFileService fileService,
    FileSystem? fileSystem,
    CacheInfoRepository? repo,
  }) {
    if (fileSystem != null && repo != null) {
      return Config(
        'image',
        fileService: fileService,
        fileSystem: fileSystem,
        repo: repo,
      );
    }
    if (fileSystem != null) {
      return Config('image', fileService: fileService, fileSystem: fileSystem);
    }
    if (repo != null) {
      return Config('image', fileService: fileService, repo: repo);
    }
    return Config('image', fileService: fileService);
  }

  /// Resolves [url] against the app database. An empty result is a clean
  /// miss and resolves to `null` — the file was simply never persisted —
  /// so callers fall back to the cache without logging an error
  /// (issue #131; previously `results.first` threw on every miss and the
  /// catch-all logged a full error + stack trace). Only genuine failures
  /// (a database error, or a persisted row whose file is gone) reject.
  Future<File?> getFromDatabase({required String url}) async {
    final results = await _fileDao.search(webUrls: [url]);
    if (results.isEmpty) return null;
    return _fileDao.file(results.first);
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    final controller = StreamController<FileResponse>();

    getFromDatabase(url: url)
        .then((file) {
          if (file == null) {
            // Clean miss (issue #131): fall back to the cache without an
            // error log — an empty database is the expected first view.
            _logbox.log(
              'Using file from cache',
              name: runtimeType.toString(),
              extra: {
                'url': url,
                'key': key,
                'headers': headers,
                'withProgress': withProgress,
              },
            );

            return controller.addStream(
              super.getFileStream(
                url,
                key: key,
                headers: headers,
                withProgress: withProgress,
              ),
            );
          }

          controller.add(
            FileInfo(
              file,
              FileSource.Cache,
              DateTime.now().add(Duration(days: 1)),
              url,
            ),
          );

          _logbox.log(
            'Using file from database',
            name: runtimeType.toString(),
            extra: {
              'url': url,
              'key': key,
              'headers': headers,
              'withProgress': withProgress,
            },
          );

          return Future<void>.value();
        })
        .onError((e, st) {
          _logbox.log(
            'Using file from cache',
            name: runtimeType.toString(),
            extra: {
              'url': url,
              'key': key,
              'headers': headers,
              'withProgress': withProgress,
            },
            error: e,
            stackTrace: st,
          );

          return controller.addStream(
            super.getFileStream(
              url,
              key: key,
              headers: headers,
              withProgress: withProgress,
            ),
          );
        })
        .whenComplete(() => controller.close());

    return controller.stream;
  }

  @override
  Future<File> getSingleFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) async {
    final File? file;
    try {
      file = await getFromDatabase(url: url);
    } catch (e, st) {
      // A real lookup failure (e.g. a persisted row whose file vanished):
      // keep the error + stack trace and fall back to the cache.
      _logbox.log(
        'Using file from cache',
        name: runtimeType.toString(),
        extra: {'url': url, 'key': key, 'headers': headers},
        error: e,
        stackTrace: st,
      );

      return super.getSingleFile(url, key: key, headers: headers);
    }

    if (file == null) {
      // Clean miss (issue #131): fall back to the cache without an error
      // log.
      _logbox.log(
        'Using file from cache',
        name: runtimeType.toString(),
        extra: {'url': url, 'key': key, 'headers': headers},
      );

      return super.getSingleFile(url, key: key, headers: headers);
    }

    _logbox.log(
      'Using file from database',
      name: runtimeType.toString(),
      extra: {'url': url, 'key': key, 'headers': headers},
    );
    return file;
  }
}
