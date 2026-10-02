// Shared mocktail mocks for ui_browse cubit tests.
//
// Mocks the domain_manga use cases and stream sources the cubits consume, so
// each cubit test constructs its subject without the real service locator.
// Stream-returning mocks are wired through [streamMocks]/[stubStreams] style
// helpers below; use them from tests via the `mock*()` factories.
//
// Keep this file free of test logic — it only declares types and default
// stubs (empty streams, sealed BehaviorSubjects).
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ui_browse/src/search_manga_screen/search_manga_screen_cubit.dart';
import 'package:ui_browse/src/search_manga_screen/search_manga_screen_state.dart';

/// Scraped-source double whose search scripts are non-empty. No real source
/// ships non-empty `searchMangaUseCase.scripts` yet (all `[]`), so recrawl
/// tests use this to prove scripts are passed through — an always-empty
/// regression would fail against [searchScripts].
class FakeScrapedSourceExternal implements SourceExternal {
  static const List<String> searchScripts = ['__stub_scraped_script__'];

  @override
  String get baseUrl => 'https://scraped.example.com';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Scraped Example';

  @override
  bool get builtIn => false;

  @override
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase =>
      throw UnimplementedError();

  @override
  GetMangaSourceExternalUseCase get getMangaUseCase =>
      throw UnimplementedError();

  @override
  ListChapterSourceExternalUseCase get listChapterUseCase =>
      throw UnimplementedError();

  @override
  ListTagSourceExternalUseCase get listTagUseCase =>
      throw UnimplementedError();

  @override
  SearchMangaSourceExternalUseCase get searchMangaUseCase =>
      _StubSearchMangaUseCase();
}

class _StubSearchMangaUseCase implements SearchMangaSourceExternalUseCase {
  @override
  Duration? get timeout => null;

  @override
  List<String> get readyWhenSelectors => [];

  @override
  List<String> get scripts => FakeScrapedSourceExternal.searchScripts;

  @override
  String url({required SearchMangaParameter parameter}) =>
      '${FakeScrapedSourceExternal().baseUrl}/browse';

  @override
  Future<List<MangaScrapped>> parse({
    required Document root,
    String? searchTerm,
  }) async => [];

  @override
  Future<bool?> haveNextPage({required Document root}) async => false;
}

class MockSearchMangaUseCase extends Mock implements SearchMangaUseCase {}

class MockGetMangaUseCase extends Mock implements GetMangaUseCase {}

class MockGetChapterUseCase extends Mock implements GetChapterUseCase {}

class MockSearchChapterUseCase extends Mock implements SearchChapterUseCase {}

class MockUpdateChapterUseCase extends Mock implements UpdateChapterUseCase {}

class MockGetNeighbourChapterUseCase extends Mock
    implements GetNeighbourChapterUseCase {}

class MockGetAllChapterUseCase extends Mock implements GetAllChapterUseCase {}

class MockPrefetchMangaUseCase extends Mock implements PrefetchMangaUseCase {}

class MockPrefetchChapterUseCase extends Mock
    implements PrefetchChapterUseCase {}

class MockAddToLibraryUseCase extends Mock implements AddToLibraryUseCase {}

class MockRemoveFromLibraryUseCase extends Mock
    implements RemoveFromLibraryUseCase {}

class MockGetTagsUseCase extends Mock implements GetTagsUseCase {}

class MockRecrawlUseCase extends Mock implements RecrawlUseCase {}

class MockListenMangaFromLibraryUseCase extends Mock
    implements ListenMangaFromLibraryUseCase {}

class MockListenPrefetchUseCase extends Mock implements ListenPrefetchUseCase {}

class MockListenSearchParameterUseCase extends Mock
    implements ListenSearchParameterUseCase {}

class MockListenReadHistoryUseCase extends Mock
    implements ListenReadHistoryUseCase {}

class MockListenDownloadedChapterUseCase extends Mock
    implements ListenDownloadedChapterUseCase {}

class MockListenPrefetchChapterConfig extends Mock
    implements ListenPrefetchChapterConfig {}

class MockListenSourcesUseCase extends Mock implements ListenSourcesUseCase {}

class MockGetMangaFromUrlUseCase extends Mock
    implements GetMangaFromUrlUseCase {}

class MockSearchMangaScreenCubit extends Mock
    implements SearchMangaScreenCubit {}

/// Stubbed, no-op [ListenMangaFromLibraryUseCase] (empty streams).
MockListenMangaFromLibraryUseCase mockListenMangaFromLibraryUseCase() {
  final mock = MockListenMangaFromLibraryUseCase();
  when(
    () => mock.libraryStateStream,
  ).thenAnswer((_) => const Stream.empty());
  when(() => mock.libraryMangaIds).thenAnswer((_) => const Stream.empty());
  return mock;
}

/// Stubbed [ListenPrefetchUseCase] (empty streams).
MockListenPrefetchUseCase mockListenPrefetchUseCase() {
  final mock = MockListenPrefetchUseCase();
  when(() => mock.mangaIdsStream).thenAnswer((_) => const Stream.empty());
  when(() => mock.chapterIdsStream).thenAnswer((_) => const Stream.empty());
  return mock;
}

/// Stubbed [ListenSearchParameterUseCase] (sealed ValueStream: valueOrNull
/// is null, so cubits keep their initialState parameter).
MockListenSearchParameterUseCase mockListenSearchParameterUseCase() {
  final mock = MockListenSearchParameterUseCase();
  when(() => mock.searchParameterState).thenAnswer(
    (_) => BehaviorSubject<SearchMangaParameter>(),
  );
  return mock;
}

/// Stubbed [ListenReadHistoryUseCase] (empty stream).
MockListenReadHistoryUseCase mockListenReadHistoryUseCase() {
  final mock = MockListenReadHistoryUseCase();
  when(
    () => mock.readHistoryStream,
  ).thenAnswer((_) => const Stream.empty());
  return mock;
}

/// Stubbed [ListenPrefetchChapterConfig] (sealed ValueStreams).
MockListenPrefetchChapterConfig mockListenPrefetchChapterConfig() {
  final mock = MockListenPrefetchChapterConfig();
  when(() => mock.numOfPrefetchedPrevChapter).thenAnswer(
    (_) => BehaviorSubject<int>(),
  );
  when(() => mock.numOfPrefetchedNextChapter).thenAnswer(
    (_) => BehaviorSubject<int>(),
  );
  return mock;
}

/// Stubbed [MockSearchMangaScreenCubit] parent for grid-widget tests.
MockSearchMangaScreenCubit mockSearchMangaScreenCubit() {
  final mock = MockSearchMangaScreenCubit();
  when(() => mock.stream).thenAnswer((_) => const Stream.empty());
  when(() => mock.state).thenReturn(SearchMangaScreenState());
  return mock;
}
