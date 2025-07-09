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
  final bool isLoadingChapters;
  final Exception? errorManga;
  final Exception? errorChapters;
  final String? mangaId;
  final Manga? manga;
  final List<Chapter> chapters;
  final int? totalChapter;
  final SourceEnum? source;
  final List<Manga> libraries;
  final Set<String> prefetchedChapterId;
  final Map<String, Chapter> histories;

  final ChapterConfig config;
  final SearchChapterParameter parameter;
  final bool hasNextPage;
  final bool isPagingNextPage;
  final String? sourceUrl;

  bool get isOnLibrary {
    return libraries.firstWhereOrNull((e) => e.id == mangaId) != null;
  }

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
      ),
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
    this.libraries = const [],
    this.prefetchedChapterId = const {},
    this.parameter = const SearchChapterParameter(),
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.sourceUrl,
    this.histories = const {},
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
        libraries,
        parameter,
        hasNextPage,
        isPagingNextPage,
        sourceUrl,
        prefetchedChapterId,
        histories,
        totalChapter,
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
    List<Manga>? libraries,
    Set<String>? prefetchedChapterId,
    SearchChapterParameter? parameter,
    bool? hasNextPage,
    bool? isPagingNextPage,
    ValueGetter<String?>? sourceUrl,
    Map<String, Chapter>? histories,
    int? totalChapter,
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
      libraries: libraries ?? this.libraries,
      parameter: parameter ?? this.parameter,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      sourceUrl: sourceUrl != null ? sourceUrl() : this.sourceUrl,
      prefetchedChapterId: prefetchedChapterId ?? this.prefetchedChapterId,
      histories: histories ?? this.histories,
      totalChapter: totalChapter ?? this.totalChapter,
    );
  }
}
