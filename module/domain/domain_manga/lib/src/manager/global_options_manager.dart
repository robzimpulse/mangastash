// GlobalOptionsManager: app-wide options persisted in SharedPreferencesAsync —
// search parameter, enabled sources, prefetch counts, downloaded-only and
// incognito — each exposed as a ValueStream plus an update method.
//
// Enabled sources (issue #115): the enabled source NAMES are stored under
// 'sources' (absent key = every source). [sourceStateStream] resolves them
// against [SourceRegistry.values] in registry order and re-resolves whenever
// the registry's entries change, so editing a script swaps in its new adapter
// without touching the stored names; names of sources that no longer exist
// resolve to nothing.
//
// Usage: `await GlobalOptionsManager.create(storage: prefs, registry: reg)`;
// call [GlobalOptionsManager.dispose] when its owner is torn down.
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/parameter/listen_search_parameter_use_case.dart';
import '../use_case/parameter/listen_setting_downloaded_only_use_case.dart';
import '../use_case/parameter/listen_setting_incognito_use_case.dart';
import '../use_case/parameter/update_search_parameter_use_case.dart';
import '../use_case/parameter/update_setting_downloaded_only_use_case.dart';
import '../use_case/parameter/update_setting_incognito_use_case.dart';
import '../use_case/prefetch/listen_prefetch_chapter_config.dart';
import '../use_case/source/listen_sources_use_case.dart';
import '../use_case/source/update_sources_use_case.dart';
import 'source_registry.dart';

class GlobalOptionsManager
    implements
        ListenSearchParameterUseCase,
        UpdateSearchParameterUseCase,
        ListenSourcesUseCase,
        UpdateSourcesUseCase,
        ListenSettingDownloadedOnlyUseCase,
        UpdateSettingDownloadedOnlyUseCase,
        ListenPrefetchChapterConfig,
        ListenSettingIncognitoUseCase,
        UpdateSettingIncognitoUseCase {
  final BehaviorSubject<SearchMangaParameter> _searchMangaParameter;
  final BehaviorSubject<List<SourceExternal>> _sources;
  final BehaviorSubject<int> _numOfPrefetchedPrevChapter;
  final BehaviorSubject<int> _numOfPrefetchedNextChapter;
  final BehaviorSubject<bool> _downloadedOnlyChapter;
  final BehaviorSubject<bool> _isIncognito;

  final SharedPreferencesAsync _storage;
  final SourceRegistry _registry;

  /// Enabled source names; null means every source.
  Set<String>? _enabledSources;
  late final StreamSubscription<void> _registrySubscription;

  static const String _mangaParameterKey = 'manga_parameter';
  static const String _sourcesKey = 'sources';
  static const String _numOfPrefetchedPrevChapterKey = 'num_of_prev_chapter';
  static const String _numOfPrefetchedNextChapterKey = 'num_of_next_chapter';
  static const String _downloadedOnlyChapterKey = 'downloaded_only_chapter';
  static const String _incognitoKey = 'is_incognito';

  static Future<GlobalOptionsManager> create({
    required SharedPreferencesAsync storage,
    required SourceRegistry registry,
  }) async {
    final incognito = await storage.getBool(_incognitoKey);
    final downloadedOnly = await storage.getBool(_downloadedOnlyChapterKey);
    final sources = await storage.getStringList(_sourcesKey);
    final parameter = await storage.getString(_mangaParameterKey);
    final numOfPrefetchedPrevChapter = await storage.getInt(
      _numOfPrefetchedPrevChapterKey,
    );
    final numOfPrefetchedNextChapter = await storage.getInt(
      _numOfPrefetchedNextChapterKey,
    );

    return GlobalOptionsManager._(
      storage: storage,
      registry: registry,
      enabledSources: sources?.toSet(),
      initialParameter: parameter
          .let(SearchMangaParameter.fromJsonString)
          .or(
            const SearchMangaParameter(
              orders: {SearchOrders.updatedAt: OrderDirections.descending},
              availableTranslatedLanguage: [LanguageCodes.english],
            ),
          ),
      numOfPrefetchedPrevChapter: numOfPrefetchedPrevChapter ?? 0,
      numOfPrefetchedNextChapter: numOfPrefetchedNextChapter ?? 0,
      downloadedOnlyChapter: downloadedOnly ?? false,
      incognito: incognito ?? false,
    );
  }

  GlobalOptionsManager._({
    required SharedPreferencesAsync storage,
    required SourceRegistry registry,
    required Set<String>? enabledSources,
    required SearchMangaParameter initialParameter,
    int numOfPrefetchedPrevChapter = 0,
    int numOfPrefetchedNextChapter = 0,
    bool downloadedOnlyChapter = false,
    bool incognito = false,
  }) : _storage = storage,
       _registry = registry,
       _enabledSources = enabledSources,
       _sources = BehaviorSubject.seeded(
         _resolveSources(registry, enabledSources),
       ),
       _searchMangaParameter = BehaviorSubject.seeded(initialParameter),
       _numOfPrefetchedNextChapter = BehaviorSubject.seeded(
         numOfPrefetchedNextChapter,
       ),
       _numOfPrefetchedPrevChapter = BehaviorSubject.seeded(
         numOfPrefetchedPrevChapter,
       ),
       _downloadedOnlyChapter = BehaviorSubject.seeded(downloadedOnlyChapter),
       _isIncognito = BehaviorSubject.seeded(incognito) {
    _registrySubscription = registry.entries.listen((_) => _publishSources());
  }

  /// Stops following the registry and closes the option streams.
  Future<void> dispose() async {
    await _registrySubscription.cancel();
    await Future.wait([
      _searchMangaParameter.close(),
      _sources.close(),
      _numOfPrefetchedPrevChapter.close(),
      _numOfPrefetchedNextChapter.close(),
      _downloadedOnlyChapter.close(),
      _isIncognito.close(),
    ]);
  }

  static List<SourceExternal> _resolveSources(
    SourceRegistry registry,
    Set<String>? enabled,
  ) {
    return [...registry.values.where((e) => enabled?.contains(e.name) ?? true)];
  }

  void _publishSources() {
    if (_sources.isClosed) return;
    final next = _resolveSources(_registry, _enabledSources);
    if (const ListEquality<SourceExternal>().equals(_sources.value, next)) {
      return;
    }
    _sources.add(next);
  }

  @override
  ValueStream<SearchMangaParameter> get searchParameterState =>
      _searchMangaParameter.stream;

  @override
  Future<void> updateSearchParameter({
    required SearchMangaParameter parameter,
  }) async {
    await _storage.setString(_mangaParameterKey, parameter.toJsonString());
    _searchMangaParameter.add(parameter);
  }

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;

  @override
  Future<void> updateSources({required List<SourceExternal> sources}) async {
    final names = [...sources.map((e) => e.name)];
    await _storage.setStringList(_sourcesKey, names);
    _enabledSources = names.toSet();
    _publishSources();
  }

  @override
  ValueStream<int> get numOfPrefetchedNextChapter {
    return _numOfPrefetchedNextChapter.stream;
  }

  @override
  ValueStream<int> get numOfPrefetchedPrevChapter {
    return _numOfPrefetchedPrevChapter.stream;
  }

  @override
  void updateNumOfPrefetchedNextChapter({required int value}) async {
    await _storage.setInt(_numOfPrefetchedNextChapterKey, value);
    _numOfPrefetchedNextChapter.add(value);
  }

  @override
  void updateNumOfPrefetchedPrevChapter({required int value}) async {
    await _storage.setInt(_numOfPrefetchedPrevChapterKey, value);
    _numOfPrefetchedPrevChapter.add(value);
  }

  @override
  ValueStream<bool> get downloadedOnlyState => _downloadedOnlyChapter.stream;

  @override
  Future<void> updateDownloadedOnly({required bool downloadedOnly}) async {
    await _storage.setBool(_downloadedOnlyChapterKey, downloadedOnly);
    _downloadedOnlyChapter.add(downloadedOnly);
  }

  @override
  ValueStream<bool> get incognitoState => _isIncognito.stream;

  @override
  Future<void> updateIncognito({required bool incognito}) async {
    await _storage.setBool(_incognitoKey, incognito);
    _isIncognito.add(incognito);
  }
}
