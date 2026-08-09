# Hide Disabled Sources App-Wide — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Disabled (unticked) sources and their saved content are hidden across every discovery surface (Search, Browse, Library, Updates, History) while rows stay in the DB and deep links keep working.

**Architecture:** Single source of truth = `GlobalOptionsManager._sources` (persisted, exposed via `ListenSourcesUseCase.sourceStateStream`). Filter at the data managers (`LibraryManager`, `HistoryManager`) so all consumer cubits get filtered data; fix the `LibraryMangaScreenCubit` seed bug; add a Search empty state. Domain fetch use cases (`Sources.fromName`) are intentionally unchanged so deep links still work.

**Tech Stack:** Dart, Flutter, rxdart (`BehaviorSubject`), `shared_preferences` (`SharedPreferencesAsync`), Drift (`MemoryExecutor` for tests), safe_bloc (`Cubit` + `AutoSubscriptionMixin`), mocktail.

## Global Constraints

- `docs/` is gitignored. Commit the plan with `git add -f`.
- Lint (via `analysis_options.yaml`): strict trailing commas (`require_trailing_commas`), single quotes, grouped/sorted imports (Dart → Package → Relative), always declare return types.
- `ValueStream` is from `package:rxdart/rxdart.dart`. `distinct()` must be called on subscriptions that emit list values, matching existing cubits.
- Follow the exact existing stream shapes: `ListenSourcesUseCase.sourceStateStream` returns `ValueStream<List<SourceExternal>>`; `LibraryDao.stream` yields `Stream<List<MangaModel>>`; `HistoryDao.history` / `.unread` yield `Stream<List<HistoryModel>>`.
- Tests use real in-memory DB: `AppDatabase(executor: MemoryExecutor())`. `AppDatabase`, DAOs, and table companions are re-exported to `domain_manga` transitively through `package:core_storage/core_storage.dart`; `MemoryExecutor` lives at `package:manga_service_drift/src/database/memory_executor.dart` and is NOT re-exported, so **Task 1 must first add `manga_service_drift` (path `../../library/manga_service_drift`) to `domain_manga`'s `dev_dependencies`** and run `melos run get`. Do not mock DAOs.

---

### Task 1: `LibraryManager` filters disabled sources

**Files:**
- Modify: `module/domain/domain_manga/pubspec.yaml` (add `manga_service_drift` dev-dependency)
- Modify: `module/domain/domain_manga/lib/src/manager/library_manager.dart`
- Test: `module/domain/domain_manga/test/manager/library_manager_test.dart`

**Interfaces:**
- Consumes: `ListenSourcesUseCase` (from `../use_case/source/listen_sources_use_case.dart`), `LibraryDao` (from `package:core_storage/core_storage.dart`), `Sources` (from `../sources/sources.dart`), `BehaviorSubject` / `combineLatest` (rxdart), `SourceExternal` (from `package:entity_manga_external/entity_manga_external.dart`).
- Produces: `LibraryManager` constructor now takes `required ListenSourcesUseCase listenSourcesUseCase`. Streams `libraryStateStream` / `libraryMangaIds` filter out rows whose `Manga.source` is not in the enabled set. Test harness uses a `BehaviorSubject<List<SourceExternal>>` for the enabled list.

- [ ] **Step 0: Add `manga_service_drift` dev-dependency**

In `module/domain/domain_manga/pubspec.yaml`, add to `dev_dependencies`:

```yaml
dev_dependencies:
  # (existing entries…)
  manga_service_drift:
    path: ../../library/manga_service_drift
```

Run from repo root: `melos run get`
Expected: resolves cleanly (the package already depends on `core_storage` which depends on `manga_service_drift`; this only exposes it to tests).

- [ ] **Step 1: Write the failing test**

Create `module/domain/domain_manga/test/manager/library_manager_test.dart`:

```dart
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  late AppDatabase db;
  late LibraryDao libraryDao;
  late MangaDao mangaDao;
  late BehaviorSubject<List<SourceExternal>> enabledSources;

  final mangas = List.generate(
    4,
    (index) => MangaTablesCompanion(
      id: Value('manga_$index'),
      title: Value('title_$index'),
      coverUrl: Value('cover_url_$index'),
      status: Value('status_$index'),
      author: Value('author_$index'),
      description: Value('description_$index'),
      webUrl: Value('web_url_$index'),
      source: Value(index.isEven ? 'Manga Dex' : 'AsuraScan'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    libraryDao = LibraryDao(db);
    mangaDao = MangaDao(db);
    enabledSources = BehaviorSubject.seeded(Sources.values);
  });

  tearDown(() async {
    await enabledSources.close();
    await db.close();
  });

  Future<LibraryManager> makeManager() async {
    for (final manga in mangas) {
      await mangaDao.adds(values: {manga: []});
      await libraryDao.add(manga.id.value);
    }
    return LibraryManager(
      libraryDao: libraryDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );
  }

  test('libraryStateStream filters out disabled-source manga', () async {
    enabledSources.add(Sources.values.where((e) => e.name != 'AsuraScan'));

    final manager = await makeManager();

    final result = await manager.libraryStateStream.first;

    expect(result.map((e) => e.title), ['title_0', 'title_2']);
  });

  test('libraryMangaIds excludes disabled-source manga ids', () async {
    enabledSources.add(Sources.values.where((e) => e.name != 'AsuraScan'));

    final manager = await makeManager();

    final result = await manager.libraryMangaIds.first;

    expect(result, {'manga_0', 'manga_2'});
  });
}

class _FakeListenSources implements ListenSourcesUseCase {
  _FakeListenSources(this._sources);

  final BehaviorSubject<List<SourceExternal>> _sources;

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;
}
```

- [ ] **Step 2: Run test to verify it fails**

Run from repo root: `fvm flutter test module/domain/domain_manga/test/manager/library_manager_test.dart`
Expected: FAIL — `LibraryManager` constructor has no `listenSourcesUseCase` parameter.

- [ ] **Step 3: Implement minimal change**

Rewrite `module/domain/domain_manga/lib/src/manager/library_manager.dart`:

```dart
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/listen_manga_from_library_use_case.dart';
import '../use_case/source/listen_sources_use_case.dart';

class LibraryManager implements ListenMangaFromLibraryUseCase {
  final LibraryDao _libraryDao;
  final ListenSourcesUseCase _listenSourcesUseCase;

  LibraryManager({
    required LibraryDao libraryDao,
    required ListenSourcesUseCase listenSourcesUseCase,
  }) : _libraryDao = libraryDao,
       _listenSourcesUseCase = listenSourcesUseCase;

  Stream<List<Manga>> get _stateSubject {
    return Rx.combineLatest2<List<MangaModel>, List<SourceExternal>, List<Manga>>(
      _libraryDao.stream,
      _listenSourcesUseCase.sourceStateStream,
      (models, sources) {
        final enabled = {...sources.map((e) => e.name)};
        return [
          for (final model in models)
            if (model.manga?.source case final source? when enabled.contains(source))
              Manga.fromDatabase(model)!,
        ];
      },
    ).shareReplay(maxSize: 1);
  }

  @override
  Stream<List<Manga>> get libraryStateStream => _stateSubject;

  @override
  Stream<Set<String>> get libraryMangaIds {
    return _stateSubject
        .map((data) => {...data.map((e) => e.id).nonNulls})
        .shareReplay(maxSize: 1);
  }
}
```

> `MangaModel.manga?.source` is the source name string; `Manga.fromDatabase(model)` maps a `MangaModel` → `Manga` (non-null when `model.manga` is non-null, which the pattern guard guarantees). `Rx.combineLatest2` is from `package:rxdart/rxdart.dart` (already imported as `import 'package:rxdart/rxdart.dart';`). Add the `SourceExternal` import: `import 'package:entity_manga_external/entity_manga_external.dart';`.

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test module/domain/domain_manga/test/manager/library_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add module/domain/domain_manga/pubspec.yaml module/domain/domain_manga/pubspec.lock module/domain/domain_manga/lib/src/manager/library_manager.dart module/domain/domain_manga/test/manager/library_manager_test.dart
git commit -m "feat(domain_manga): filter LibraryManager rows by enabled sources"
```

> If `melos run get` produced no `pubspec.lock` for `domain_manga` (workspace lockfile layout varies), omit it from the `git add` — the other three paths must still be staged.

---

### Task 2: `HistoryManager` filters disabled sources

**Files:**
- Modify: `module/domain/domain_manga/lib/src/manager/history_manager.dart`
- Test: `module/domain/domain_manga/test/manager/history_manager_test.dart`

**Interfaces:**
- Consumes: `ListenSourcesUseCase`, `HistoryDao` (`history` / `unread` streams), `ListenReadHistoryUseCase` / `ListenUnreadHistoryUseCase` (unchanged), `HistoryModel`, `MangaChapter.fromDrift`.
- Produces: `HistoryManager` constructor gains `required ListenSourcesUseCase listenSourcesUseCase`. Both `readHistoryStream` and `unreadHistoryStream` drop `MangaChapter`s whose `manga?.source` is not in the enabled set.

- [ ] **Step 1: Write the failing test**

Create `module/domain/domain_manga/test/manager/history_manager_test.dart`:

```dart
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  late AppDatabase db;
  late HistoryDao historyDao;
  late MangaDao mangaDao;
  late ChapterDao chapterDao;
  late LibraryDao libraryDao;
  late BehaviorSubject<List<SourceExternal>> enabledSources;

  final mangas = List.generate(
    2,
    (index) => MangaTablesCompanion(
      id: Value('manga_$index'),
      title: Value('title_$index'),
      coverUrl: Value('cover_url_$index'),
      status: Value('status_$index'),
      author: Value('author_$index'),
      description: Value('description_$index'),
      webUrl: Value('web_url_$index'),
      source: Value(index.isEven ? 'Manga Dex' : 'AsuraScan'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  final chapters = List.generate(
    2,
    (index) => ChapterTablesCompanion(
      id: Value('chapter_$index'),
      mangaId: Value('manga_$index'),
      title: Value('chapter_title_$index'),
      chapter: Value('$index'),
      readableAt: Value(DateTime.now()),
      publishAt: Value(DateTime.now()),
      lastReadAt: Value(DateTime.now()),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
    historyDao = HistoryDao(db);
    mangaDao = MangaDao(db);
    chapterDao = ChapterDao(db);
    libraryDao = LibraryDao(db);
    enabledSources = BehaviorSubject.seeded(Sources.values);
  });

  tearDown(() async {
    await enabledSources.close();
    await db.close();
  });

  Future<void> seedHistory() async {
    for (var i = 0; i < 2; i++) {
      await mangaDao.adds(values: {mangas[i]: []});
      await chapterDao.adds(values: [chapters[i]]);
      await historyDao.markAsRead(chapterId: 'chapter_$i');
    }
  }

  test('readHistoryStream filters disabled-source history', () async {
    await seedHistory();
    enabledSources.add(Sources.values.where((e) => e.name != 'AsuraScan'));

    final manager = HistoryManager(
      historyDao: historyDao,
      listenSourcesUseCase: _FakeListenSources(enabledSources),
    );

    final result = await manager.readHistoryStream.first;

    expect(result.single.manga?.title, 'title_0');
  });
}

class _FakeListenSources implements ListenSourcesUseCase {
  _FakeListenSources(this._sources);

  final BehaviorSubject<List<SourceExternal>> _sources;

  @override
  ValueStream<List<SourceExternal>> get sourceStateStream => _sources.stream;
}
```

> `ListenSourcesUseCase`, `ValueStream`, and `HistoryManager` come from `package:domain_manga/domain_manga.dart`; `HistoryDao`, `MangaDao`, `ChapterDao`, `LibraryDao`, `HistoryModel`, and the `MangaTablesCompanion` / `ChapterTablesCompanion` / `Value` helpers come from `package:manga_service_drift/manga_service_drift.dart`. If `HistoryDao` or the companions are not exported from the barrel, import them from their source paths directly (e.g. `package:manga_service_drift/src/dao/history_dao.dart`, `package:manga_service_drift/src/tables/...`), matching how `library_dao_test.dart` imports `MemoryExecutor` from `src/`.

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test module/domain/domain_manga/test/manager/history_manager_test.dart`
Expected: FAIL — `HistoryManager` constructor lacks `listenSourcesUseCase`.

- [ ] **Step 3: Implement minimal change**

Rewrite `module/domain/domain_manga/lib/src/manager/history_manager.dart`:

```dart
import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/src/manga_chapter.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/history/listen_read_history_use_case.dart';
import '../use_case/history/listen_unread_history_use_case.dart';
import '../use_case/source/listen_sources_use_case.dart';

class HistoryManager
    implements ListenReadHistoryUseCase, ListenUnreadHistoryUseCase {
  final HistoryDao _historyDao;
  final ListenSourcesUseCase _listenSourcesUseCase;

  HistoryManager({
    required HistoryDao historyDao,
    required ListenSourcesUseCase listenSourcesUseCase,
  }) : _historyDao = historyDao,
       _listenSourcesUseCase = listenSourcesUseCase;

  Stream<List<MangaChapter>> _filter(Stream<List<HistoryModel>> source) {
    return source.withLatestFrom(
      _listenSourcesUseCase.sourceStateStream,
      (histories, sources) {
        final enabled = {...sources.map((e) => e.name)};
        return [
          for (final model in histories)
            if (model.manga?.source case final source? when enabled.contains(source))
              MangaChapter.fromDrift(model),
        ];
      },
    );
  }

  @override
  Stream<List<MangaChapter>> get readHistoryStream {
    return _filter(_historyDao.history);
  }

  @override
  Stream<List<MangaChapter>> get unreadHistoryStream {
    return _filter(_historyDao.unread);
  }
}
```

> `model.manga?.source` is the source name string on the raw Drift manga; the pattern guard ensures non-null, so `MangaChapter.fromDrift(model)` (which carries the same `source` through) is the only survivor. `withLatestFrom` needs the enabled list to have emitted at least once — the seed in tests / `BehaviorSubject.seeded` in production guarantees that. `HistoryDao`, `HistoryModel`, and the DAOs are exported by `package:core_storage/core_storage.dart`.

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test module/domain/domain_manga/test/manager/history_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add module/domain/domain_manga/lib/src/manager/history_manager.dart module/domain/domain_manga/test/manager/history_manager_test.dart
git commit -m "feat(domain_manga): filter HistoryManager rows by enabled sources"
```

---

### Task 3: Wire `ListenSourcesUseCase` into both managers

**Files:**
- Modify: `module/domain/domain_manga/lib/src/domain_manga_registrar.dart`

**Interfaces:**
- Consumes: constructors from Task 1 / Task 2 (both require `ListenSourcesUseCase`).
- Produces: no new interfaces.

- [ ] **Step 1: Update registrar to pass the dependency**

In `module/domain/domain_manga/lib/src/domain_manga_registrar.dart`, change:

```dart
    locator.registerLazySingleton(() => LibraryManager(libraryDao: locator()));
    locator.alias<ListenMangaFromLibraryUseCase, LibraryManager>();
```

to:

```dart
    locator.registerLazySingleton(
      () => LibraryManager(
        libraryDao: locator(),
        listenSourcesUseCase: locator(),
      ),
    );
    locator.alias<ListenMangaFromLibraryUseCase, LibraryManager>();
```

And change:

```dart
    locator.registerLazySingleton(() => HistoryManager(historyDao: locator()));
```

to:

```dart
    locator.registerLazySingleton(
      () => HistoryManager(
        historyDao: locator(),
        listenSourcesUseCase: locator(),
      ),
    );
```

`locator()` resolves `ListenSourcesUseCase` because `DomainMangaRegistrar` already registers `alias<ListenSourcesUseCase, GlobalOptionsManager>()` above.

- [ ] **Step 2: Verify the package analyzes**

Run from repo root: `fvm flutter analyze module/domain/domain_manga`
Expected: no new issues.

- [ ] **Step 3: Commit**

```bash
git add module/domain/domain_manga/lib/src/domain_manga_registrar.dart
git commit -m "feat(domain_manga): inject ListenSourcesUseCase into managers"
```

---

### Task 4: Fix `LibraryMangaScreenCubit` seed + subscribe to enabled sources

**Files:**
- Modify: `module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen_cubit.dart`
- Modify: `module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen.dart:28-54`

**Interfaces:**
- Consumes: `ListenSourcesUseCase` (resolved via `locator()` in `LibraryMangaScreen.create`).
- Produces: `LibraryMangaScreenCubit` constructor gains `required ListenSourcesUseCase listenSourcesUseCase`. Initial `sources` = current enabled set (via `sourceStateStream.valueOrNull ?? const []`), plus a subscription that emits on changes (same pattern as `SearchMangaScreenCubit` / `BrowseSourceScreenCubit`). `LibraryMangaScreen.create` passes `listenSourcesUseCase: locator()`.

- [ ] **Step 1: Update the cubit**

In `module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen_cubit.dart`, change the constructor to require the new dependency and subscribe:

```dart
  LibraryMangaScreenCubit({
    LibraryMangaScreenState initialState = const LibraryMangaScreenState(),
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required GetMangaFromUrlUseCase getMangaFromUrlUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required ListenSourcesUseCase listenSourcesUseCase,
  })  : _prefetchMangaUseCase = prefetchMangaUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        _getMangaFromUrlUseCase = getMangaFromUrlUseCase,
        super(
          initialState.copyWith(
            sources: listenSourcesUseCase.sourceStateStream.valueOrNull ?? const [],
          ),
        ) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateLibraryState),
    );
    addSubscription(
      listenPrefetchMangaUseCase.mangaIdsStream
          .distinct()
          .listen(_updatePrefetchState),
    );
    addSubscription(
      listenSourcesUseCase.sourceStateStream.distinct().listen(
        (sources) => emit(state.copyWith(sources: sources)),
      ),
    );
  }
```

- [ ] **Step 2: Update `LibraryMangaScreen.create`**

In `module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen.dart`, add `listenSourcesUseCase: locator(),` to the `LibraryMangaScreenCubit(...)` call (line ~37):

```dart
        return LibraryMangaScreenCubit(
          listenMangaFromLibraryUseCase: locator(),
          listenSourcesUseCase: locator(),
          prefetchMangaUseCase: locator(),
          ...
        );
```

- [ ] **Step 3: Verify the package analyzes**

Run: `fvm flutter analyze module/ui/ui_browse`
Expected: no new issues.

- [ ] **Step 4: Commit**

```bash
git add module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen_cubit.dart module/ui/ui_browse/lib/src/library_manga_screen/library_manga_screen.dart
git commit -m "feat(ui_browse): LibraryMangaScreenCubit subscribes to enabled sources"
```

---

### Task 5: Search screen empty state

**Files:**
- Modify: `module/ui/ui_browse/lib/src/search_manga_screen/search_manga_screen.dart`
- Modify: `module/feature/feature_browse/lib/src/route_builder.dart:200-232`

**Interfaces:**
- Consumes: `SearchMangaScreenState.sources` (empty ⇒ empty state), new `onTapBrowseSources` callback.
- Produces: `SearchMangaScreen.create` gains optional `VoidCallback? onTapBrowseSources`; the widget takes it as a field. `SearchMangaScreenState` is unchanged.

- [ ] **Step 1: Add the callback + empty state**

In `module/ui/ui_browse/lib/src/search_manga_screen/search_manga_screen.dart`:

Add a field and constructor param to the widget:

```dart
  final VoidCallback? onTapBrowseSources;
```

```dart
  const SearchMangaScreen({
    super.key,
    required this.imagesCacheManager,
    required this.widgetBuilder,
    this.onTapFilter,
    this.onTapBrowseSources,
  });
```

Add it to `create(...)`:

```dart
  static Widget create({
    required ServiceLocator locator,
    void Function(Manga, SearchMangaParameter)? onTapManga,
    Future<MangaMenu?> Function(bool)? onTapMangaMenu,
    Future<SearchMangaParameter?>? Function(SearchMangaParameter? value)?
    onTapFilter,
    VoidCallback? onTapBrowseSources,
  }) {
```

And pass to the widget:

```dart
      child: SearchMangaScreen(
        imagesCacheManager: locator(),
        onTapFilter: onTapFilter,
        onTapBrowseSources: onTapBrowseSources,
        widgetBuilder: (source, cubit) {
          ...
        },
      ),
```

In `build`, before the `DefaultTabController` return, branch on empty sources:

```dart
        if (state.sources.isEmpty) {
          return ScaffoldScreen(
            appBar: AppBar(
              title: const Text('Search Manga'),
              centerTitle: false,
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No sources enabled'),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: widget.onTapBrowseSources,
                    child: const Text('Open Source List'),
                  ),
                ],
              ),
            ),
          );
        }
```

- [ ] **Step 2: Wire the callback in the route builder**

In `module/feature/feature_browse/lib/src/route_builder.dart`, in the `searchManga` route builder, pass `onTapBrowseSources` to `SearchMangaScreen.create`:

```dart
          return SearchMangaScreen.create(
            locator: locator,
            onTapBrowseSources: () {
              context.push(BrowseRoutePath.browse);
            },
            onTapFilter: (param) {
              ...
            },
            ...
          );
```

- [ ] **Step 3: Verify both packages analyze**

Run: `fvm flutter analyze module/ui/ui_browse module/feature/feature_browse`
Expected: no new issues.

- [ ] **Step 4: Commit**

```bash
git add module/ui/ui_browse/lib/src/search_manga_screen/search_manga_screen.dart module/feature/feature_browse/lib/src/route_builder.dart
git commit -m "feat(ui_browse): empty state when no sources enabled"
```

---

### Task 6: Full workspace verification

**Files:**
- None (verification only).

- [ ] **Step 1: Run the manager tests**

Run from repo root: `fvm flutter test module/domain/domain_manga/test/manager`
Expected: PASS (Tasks 1 + 2).

- [ ] **Step 2: Run the full test suite**

Run: `melos run test`
Expected: all tests pass. If `melos run test` is unavailable or slow in your environment, run `fvm flutter test` per affected module (`domain_manga`, `ui_browse`, `feature_browse`) instead.

- [ ] **Step 3: Run the analyzer across all packages**

Run: `melos run analyze`
Expected: no new issues.

- [ ] **Step 4: Commit any fixes**

If any step produced fixes, commit them with a descriptive message; otherwise nothing to commit.
