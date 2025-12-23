import 'dart:async';

import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/cache_store.dart';

typedef DeletedFileData = (CacheObject object, File file);

class CustomCacheStore implements CacheStore {
  @override
  Duration cleanupRunMinInterval = const Duration(seconds: 10);

  final _futureCache = <String, Future<CacheObject?>>{};
  final _memCache = <String, CacheObject>{};

  Future<Set<String>> get keys async {
    final provider = await _cacheInfoRepository;
    final objects = await provider.getAllObjects();
    return {
      ...objects.map((e) => e.key).nonNulls,
      ..._futureCache.keys.nonNulls,
      ..._memCache.keys.nonNulls,
    };
  }

  @override
  FileSystem fileSystem;

  final Config _config;

  @override
  String get storeKey => _config.cacheKey;
  final Future<CacheInfoRepository> _cacheInfoRepository;

  int get _capacity => _config.maxNrOfCacheObjects;

  Duration get _maxAge => _config.stalePeriod;

  @override
  DateTime lastCleanupRun = DateTime.now();
  Timer? _scheduledCleanup;

  final _controller = StreamController<DeletedFileData>.broadcast();

  Stream<DeletedFileData> get deleteFileEvent => _controller.stream;

  CustomCacheStore(Config config)
    : _config = config,
      fileSystem = config.fileSystem,
      _cacheInfoRepository = config.repo.open().then((value) => config.repo);

  @override
  Future<FileInfo?> getFile(String key, {bool ignoreMemCache = false}) async {
    final cacheObject = await retrieveCacheData(
      key,
      ignoreMemCache: ignoreMemCache,
    );
    if (cacheObject == null) {
      return null;
    }
    final file = await fileSystem.createFile(cacheObject.relativePath);
    cacheLogger.log(
      'CacheManager: Loaded $key from cache',
      CacheManagerLogLevel.verbose,
    );

    return FileInfo(
      file,
      FileSource.Cache,
      cacheObject.validTill,
      cacheObject.url,
    );
  }

  @override
  Future<void> putFile(CacheObject cacheObject) async {
    _memCache[cacheObject.key] = cacheObject;
    final dynamic out = await _updateCacheDataInDatabase(cacheObject);

    // We update the cache object with the id if returned by the repository
    if (out is CacheObject && out.id != null) {
      _memCache[cacheObject.key] = cacheObject.copyWith(id: out.id);
    }
  }

  @override
  Future<CacheObject?> retrieveCacheData(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    if (!ignoreMemCache && _memCache.containsKey(key)) {
      if (await _fileExists(_memCache[key])) {
        return _memCache[key];
      }
    }
    if (!_futureCache.containsKey(key)) {
      final completer = Completer<CacheObject?>();
      _getCacheDataFromDatabase(key).then((cacheObject) async {
        if (cacheObject?.id != null && !await _fileExists(cacheObject)) {
          final provider = await _cacheInfoRepository;
          await provider.delete(cacheObject!.id!);
          cacheObject = null;
        }

        if (cacheObject == null) {
          _memCache.remove(key);
        } else {
          _memCache[key] = cacheObject;
        }
        completer.complete(cacheObject);
        _futureCache.remove(key);
      });
      _futureCache[key] = completer.future;
    }
    return _futureCache[key];
  }

  @override
  Future<FileInfo?> getFileFromMemory(String key) async {
    final cacheObject = _memCache[key];
    if (cacheObject == null) {
      return null;
    }
    final file = await fileSystem.createFile(cacheObject.relativePath);
    return FileInfo(
      file,
      FileSource.Cache,
      cacheObject.validTill,
      cacheObject.url,
    );
  }

  Future<bool> _fileExists(CacheObject? cacheObject) async {
    if (cacheObject == null) {
      return false;
    }
    final file = await fileSystem.createFile(cacheObject.relativePath);
    return file.exists();
  }

  Future<CacheObject?> _getCacheDataFromDatabase(String key) async {
    final provider = await _cacheInfoRepository;
    final data = await provider.get(key);
    if (await _fileExists(data)) {
      _updateCacheDataInDatabase(data!);
    }
    _scheduleCleanup();
    return data;
  }

  void _scheduleCleanup() {
    if (_scheduledCleanup != null) {
      return;
    }
    _scheduledCleanup = Timer(cleanupRunMinInterval, () {
      _scheduledCleanup = null;
      _cleanupCache();
    });
  }

  Future<dynamic> _updateCacheDataInDatabase(CacheObject cacheObject) async {
    final provider = await _cacheInfoRepository;
    return provider.updateOrInsert(cacheObject);
  }

  Future<void> _cleanupCache() async {
    final toRemove = <int>[];
    final provider = await _cacheInfoRepository;

    final overCapacity = await provider.getObjectsOverCapacity(_capacity);
    for (final cacheObject in overCapacity) {
      _removeCachedFile(cacheObject, toRemove);
    }

    final oldObjects = await provider.getOldObjects(_maxAge);
    for (final cacheObject in oldObjects) {
      _removeCachedFile(cacheObject, toRemove);
    }

    await provider.deleteAll(toRemove);
  }

  @override
  Future<void> emptyCache() async {
    final provider = await _cacheInfoRepository;
    final toRemove = <int>[];
    final allObjects = await provider.getAllObjects();
    var futures = <Future>[];
    for (final cacheObject in allObjects) {
      futures.add(_removeCachedFile(cacheObject, toRemove));
    }
    await Future.wait(futures);
    await provider.deleteAll(toRemove);
  }

  @override
  void emptyMemoryCache() {
    _memCache.clear();
  }

  @override
  Future<void> removeCachedFile(CacheObject cacheObject) async {
    final provider = await _cacheInfoRepository;
    final toRemove = <int>[];
    await _removeCachedFile(cacheObject, toRemove);
    await provider.deleteAll(toRemove);
  }

  Future<void> _removeCachedFile(
    CacheObject cacheObject,
    List<int> toRemove,
  ) async {
    if (toRemove.contains(cacheObject.id)) return;

    toRemove.add(cacheObject.id!);
    if (_memCache.containsKey(cacheObject.key)) {
      _memCache.remove(cacheObject.key);
    }
    if (_futureCache.containsKey(cacheObject.key)) {
      await _futureCache.remove(cacheObject.key);
    }

    final file = await fileSystem.createFile(cacheObject.relativePath);

    if (file.existsSync()) {
      _controller.add((cacheObject, file));
    }
  }

  @override
  bool memoryCacheContainsKey(String key) {
    return _memCache.containsKey(key);
  }

  @override
  Future<void> dispose() async {
    final provider = await _cacheInfoRepository;
    await provider.close();
    await _controller.close();
  }

  @override
  Future<int> getCacheSize() async {
    final provider = await _cacheInfoRepository;
    final allObjects = await provider.getAllObjects();
    int total = 0;
    for (var cacheObject in allObjects) {
      total += cacheObject.length ?? 0;
    }
    return total;
  }
}
