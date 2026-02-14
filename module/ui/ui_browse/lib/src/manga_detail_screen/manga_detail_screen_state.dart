import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class MangaDetailScreenState extends Equatable {
  final bool isLoadingManga;
  final Exception? errorManga;
  final String? mangaId;
  final Manga? manga;
  final SourceEnum? source;

  final bool isLoadingChapters;
  final Exception? errorChapters;
  final List<Chapter> chapters;
  final int? totalChapter;
  final String? sourceUrlChapter;
  final bool hasNextPageChapter;
  final bool isPagingNextPageChapter;
  final ChapterConfig config;
  final SearchChapterParameter chapterParameter;

  final bool isLoadingSimilarManga;
  final Exception? errorSimilarManga;
  final bool hasNextPageSimilarManga;
  final bool isPagingNextPageSimilarManga;
  final List<Manga> similarManga;
  final String? sourceUrlSimilarManga;
  final SearchMangaParameter? similarMangaParameter;

  final Set<String> libraryMangaIds;
  final Set<String> prefetchedChapterIds;
  final Set<String> prefetchedMangaIds;
  final Map<String, Chapter> histories;
  final Set<String> downloadedChapterIds;

  bool get isOnLibrary => libraryMangaIds.contains(mangaId);

  List<Chapter> get filtered {
    final List<Chapter> result = [];

    for (final chapter in chapters) {
      final history = histories[chapter.id];
      final data = history ?? chapter;

      final criteria = [
        if (config.unread == null)
          // filter chapter that has been read
          data.lastReadAt != null
        else if (config.unread == true)
          // filter chapter that as been unread
          data.lastReadAt == null
        else if (config.unread == false)
          // ignore filter unread
          true,

        if (config.downloaded == null)
          // filter chapter that hasn't been downloaded
          !downloadedChapterIds.contains(data.id)
        else if (config.downloaded == true)
          // filter chapter that has been downloaded
          downloadedChapterIds.contains(data.id)
        else if (config.downloaded == false)
          // ignore filter downloaded
          true,
      ];

      if (criteria.every((e) => e)) {
        result.add(data.copyWith(lastReadAt: history?.lastReadAt));
      }
    }

    return result;
  }

  const MangaDetailScreenState({
    this.isLoadingManga = false,
    this.isLoadingChapters = false,
    this.totalChapter,
    this.errorManga,
    this.errorChapters,
    this.mangaId,
    this.manga,
    this.chapters = const [],
    this.source,
    this.config = const ChapterConfig(),
    this.libraryMangaIds = const {},
    this.prefetchedChapterIds = const {},
    this.prefetchedMangaIds = const {},
    this.chapterParameter = const SearchChapterParameter(),
    this.hasNextPageChapter = false,
    this.isPagingNextPageChapter = false,
    this.sourceUrlChapter,
    this.histories = const {},
    this.errorSimilarManga,
    this.isLoadingSimilarManga = false,
    this.hasNextPageSimilarManga = false,
    this.isPagingNextPageSimilarManga = false,
    this.similarManga = const [],
    this.sourceUrlSimilarManga,
    this.similarMangaParameter,
    this.downloadedChapterIds = const {},
  });

  @override
  List<Object?> get props => [
    isLoadingManga,
    isLoadingChapters,
    errorManga,
    errorChapters,
    mangaId,
    manga,
    chapters,
    source,
    config,
    libraryMangaIds,
    chapterParameter,
    hasNextPageChapter,
    isPagingNextPageChapter,
    sourceUrlChapter,
    prefetchedChapterIds,
    prefetchedMangaIds,
    histories,
    totalChapter,
    errorSimilarManga,
    isLoadingSimilarManga,
    hasNextPageSimilarManga,
    isPagingNextPageSimilarManga,
    similarManga,
    sourceUrlSimilarManga,
    similarMangaParameter,
    downloadedChapterIds,
  ];

  MangaDetailScreenState copyWith({
    bool? isLoadingManga,
    bool? isLoadingChapters,
    ValueGetter<Exception?>? errorChapters,
    ValueGetter<Exception?>? errorManga,
    String? mangaId,
    Manga? manga,
    List<Chapter>? chapters,
    String? sourceId,
    SourceEnum? source,
    ChapterConfig? config,
    Set<String>? libraryMangaIds,
    Set<String>? prefetchedChapterIds,
    Set<String>? prefetchedMangaIds,
    SearchChapterParameter? chapterParameter,
    bool? hasNextPageChapter,
    bool? isPagingNextPageChapter,
    ValueGetter<String?>? sourceUrlChapter,
    Map<String, Chapter>? histories,
    int? totalChapter,
    ValueGetter<Exception?>? errorSimilarManga,
    bool? isLoadingSimilarManga,
    bool? hasNextPageSimilarManga,
    bool? isPagingNextPageSimilarManga,
    List<Manga>? similarManga,
    ValueGetter<String?>? sourceUrlSimilarManga,
    SearchMangaParameter? similarMangaParameter,
    Set<String>? downloadedChapterIds,
  }) {
    return MangaDetailScreenState(
      config: config ?? this.config,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      isLoadingManga: isLoadingManga ?? this.isLoadingManga,
      errorChapters:
          errorChapters != null ? errorChapters() : this.errorChapters,
      errorManga: errorManga != null ? errorManga() : this.errorManga,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      source: source ?? this.source,
      libraryMangaIds: libraryMangaIds ?? this.libraryMangaIds,
      chapterParameter: chapterParameter ?? this.chapterParameter,
      hasNextPageChapter: hasNextPageChapter ?? this.hasNextPageChapter,
      isPagingNextPageChapter:
          isPagingNextPageChapter ?? this.isPagingNextPageChapter,
      sourceUrlChapter:
          sourceUrlChapter != null ? sourceUrlChapter() : this.sourceUrlChapter,
      prefetchedChapterIds: prefetchedChapterIds ?? this.prefetchedChapterIds,
      prefetchedMangaIds: prefetchedMangaIds ?? this.prefetchedMangaIds,
      histories: histories ?? this.histories,
      totalChapter: totalChapter ?? this.totalChapter,
      errorSimilarManga:
          errorSimilarManga != null
              ? errorSimilarManga()
              : this.errorSimilarManga,
      isLoadingSimilarManga:
          isLoadingSimilarManga ?? this.isLoadingSimilarManga,
      hasNextPageSimilarManga:
          hasNextPageSimilarManga ?? this.hasNextPageSimilarManga,
      isPagingNextPageSimilarManga:
          isPagingNextPageSimilarManga ?? this.isPagingNextPageSimilarManga,
      similarManga: similarManga ?? this.similarManga,
      similarMangaParameter:
          similarMangaParameter ?? this.similarMangaParameter,
      sourceUrlSimilarManga:
          sourceUrlSimilarManga != null
              ? sourceUrlSimilarManga()
              : this.sourceUrlSimilarManga,
      downloadedChapterIds: downloadedChapterIds ?? this.downloadedChapterIds,
    );
  }
}
