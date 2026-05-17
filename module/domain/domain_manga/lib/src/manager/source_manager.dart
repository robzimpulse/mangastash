import 'package:collection/collection.dart';
import 'package:core_runtime/core_runtime.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:rxdart/rxdart.dart';

import '../sources/built_in_source_provider.dart';
import '../sources/dynamic_source_external.dart';

abstract class SourceManager {
  Stream<List<SourceExternal>> watchAllSources();
  List<SourceExternal> get currentSources;
  SourceExternal? getSource(String name);
  SourceExternal? getSourceByUri(Uri uri);
}

class SourceManagerImpl implements SourceManager {
  final BuiltInSourceProvider _builtInSourceProvider;
  final DynamicSourceDao _dynamicSourceDao;
  final SourceRuntime _sourceRuntime;

  final BehaviorSubject<List<SourceExternal>> _allSourcesSubject = BehaviorSubject();

  SourceManagerImpl({
    required BuiltInSourceProvider builtInSourceProvider,
    required DynamicSourceDao dynamicSourceDao,
    required SourceRuntime sourceRuntime,
  }) : _builtInSourceProvider = builtInSourceProvider,
       _dynamicSourceDao = dynamicSourceDao,
       _sourceRuntime = sourceRuntime {
    _init();
  }

  void _init() {
    Rx.combineLatest2(
      Stream.value(_builtInSourceProvider.sources),
      _dynamicSourceDao.watchAll(),
      (builtIn, dynamicDrift) {
        final dynamicSources = dynamicDrift
            .where((e) => e.isActive)
            .map(
              (e) => DynamicSourceExternal(
                name: e.name,
                baseUrl: e.baseUrl,
                iconUrl: e.iconUrl ?? '',
                bytecode: e.bytecode,
                runtime: _sourceRuntime,
              ),
            )
            .toList();
        return [...builtIn, ...dynamicSources];
      },
    ).listen(_allSourcesSubject.add);
  }

  @override
  Stream<List<SourceExternal>> watchAllSources() => _allSourcesSubject.stream;

  @override
  List<SourceExternal> get currentSources => _allSourcesSubject.valueOrNull ?? _builtInSourceProvider.sources;

  @override
  SourceExternal? getSource(String name) {
    return currentSources.firstWhereOrNull((e) => e.name == name);
  }

  @override
  SourceExternal? getSourceByUri(Uri uri) {
    for (final source in currentSources) {
      if (Uri.tryParse(source.baseUrl)?.host == uri.host) {
        return source;
      }
    }
    return null;
  }

  void dispose() {
    _allSourcesSubject.close();
  }
}
