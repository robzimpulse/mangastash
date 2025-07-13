import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

enum DownloadOption {
  unread('Unread'),
  all('All');

  final String value;

  const DownloadOption(this.value);
}

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

  final Set<String> libraryMangaId;
  final Set<String> prefetchedChapterId;
  final Map<String, Chapter> histories;

  bool get isOnLibrary => libraryMangaId.contains(mangaId);

  List<Chapter> get filtered {
    return [
      ...chapters.where(
        (data) {
          final chapter = histories[data.id].or(data);

          final shouldAdd = [
            if (config.unread == true)
              chapter.lastReadAt == null
            else if (config.unread == null)
              chapter.lastReadAt != null
            else
              true,
          ];

          return shouldAdd.contains(true);
        },
      ).map((e) => e.copyWith(lastReadAt: histories[e.id]?.lastReadAt)),
    ];
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
    this.libraryMangaId = const {},
    this.prefetchedChapterId = const {},
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
        libraryMangaId,
        chapterParameter,
        hasNextPageChapter,
        isPagingNextPageChapter,
        sourceUrlChapter,
        prefetchedChapterId,
        histories,
        totalChapter,
        errorSimilarManga,
        isLoadingSimilarManga,
        hasNextPageSimilarManga,
        isPagingNextPageSimilarManga,
        similarManga,
        sourceUrlSimilarManga,
        similarMangaParameter,
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
    Set<String>? libraryMangaId,
    Set<String>? prefetchedChapterId,
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
      libraryMangaId: libraryMangaId ?? this.libraryMangaId,
      chapterParameter: chapterParameter ?? this.chapterParameter,
      hasNextPageChapter: hasNextPageChapter ?? this.hasNextPageChapter,
      isPagingNextPageChapter:
          isPagingNextPageChapter ?? this.isPagingNextPageChapter,
      sourceUrlChapter:
          sourceUrlChapter != null ? sourceUrlChapter() : this.sourceUrlChapter,
      prefetchedChapterId: prefetchedChapterId ?? this.prefetchedChapterId,
      histories: histories ?? this.histories,
      totalChapter: totalChapter ?? this.totalChapter,
      errorSimilarManga: errorSimilarManga != null
          ? errorSimilarManga()
          : this.errorSimilarManga,
      isLoadingSimilarManga: isLoadingManga ?? this.isLoadingSimilarManga,
      hasNextPageSimilarManga:
          hasNextPageSimilarManga ?? this.hasNextPageSimilarManga,
      isPagingNextPageSimilarManga:
          isPagingNextPageSimilarManga ?? this.isPagingNextPageSimilarManga,
      similarManga: similarManga ?? this.similarManga,
      similarMangaParameter:
          similarMangaParameter ?? this.similarMangaParameter,
      sourceUrlSimilarManga: sourceUrlSimilarManga != null
          ? sourceUrlSimilarManga()
          : this.sourceUrlSimilarManga,
    );
  }
}
