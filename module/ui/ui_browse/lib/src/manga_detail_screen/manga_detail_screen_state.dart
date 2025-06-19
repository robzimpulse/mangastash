import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
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
  final List<Chapter>? chapters;
  final Source? source;
  final AuthState? authState;
  final List<Manga> libraries;
  final Map<DownloadChapterKey, DownloadChapterProgress>? progress;
  final Set<String> prefetchedChapterId;
  final Map<num, Chapter> histories;

  final ChapterConfig config;
  final SearchChapterParameter parameter;
  final bool hasNextPage;
  final bool isPagingNextPage;
  final String? sourceUrl;

  late final Set<num> chaptersKey;
  late final Map<num, Chapter> processedChapters;
  late final int totalChapter;

  bool get isOnLibrary {
    return libraries.firstWhereOrNull((e) => e.id == mangaId) != null;
  }

  MangaDetailScreenState({
    this.isLoadingManga = false,
    this.isLoadingChapters = false,
    this.errorManga,
    this.errorChapters,
    this.mangaId,
    this.manga,
    this.chapters,
    this.source,
    this.config = const ChapterConfig(),
    this.authState,
    this.libraries = const [],
    this.prefetchedChapterId = const {},
    this.progress,
    this.parameter = const SearchChapterParameter(),
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.sourceUrl,
    this.histories = const {},
  }) {
    final Map<num, Chapter> processedChapters = {};
    final List<String> chapterIds = [];

    for (final data in chapters ?? <Chapter>[]) {
      final chapter = data.chapter?.let((e) => num.tryParse(e));

      if (chapter != null) {
        processedChapters.update(
          chapter,
          (value) {
            final oldDate = value.publishAt;
            final newDate = data.publishAt;

            if (oldDate != null && newDate != null) {
              return newDate.isBefore(oldDate) ? value : data;
            }

            return data;
          },
          ifAbsent: () => data,
        );
      }
    }

    final reversedChaptersKey = {
      ...processedChapters.keys.sorted((a, b) => a.compareTo(b)),
    };

    this.processedChapters = processedChapters;
    chaptersKey = {...processedChapters.keys.sorted((a, b) => b.compareTo(a))};
    totalChapter = processedChapters.length;

    for (final key in reversedChaptersKey) {
      final id = processedChapters[key]?.id;
      if (id != null) chapterIds.add(id);
    }

    // TODO: perform sorting

    // final sortOrder = config?.sortOrder;
    // final sortOption = config?.sortOption;
    // List<MangaChapter>? processedChapters;

    // if (sortOrder != null && sortOption != null) {
    //   switch (sortOption) {
    //     case MangaChapterSortOptionEnum.chapterNumber:
    //       switch (sortOrder) {
    //         case MangaChapterSortOrderEnum.asc:
    //           processedChapters = chapters?.sorted(
    //             (a, b) {
    //               final aChapter = int.tryParse(a.chapter ?? '');
    //               final bChapter = int.tryParse(b.chapter ?? '');
    //               if (aChapter == null || bChapter == null) return 0;
    //               return -aChapter.compareTo(bChapter);
    //             },
    //           );
    //           break;
    //         case MangaChapterSortOrderEnum.desc:
    //           processedChapters = chapters?.sorted(
    //             (a, b) {
    //               final aChapter = int.tryParse(a.chapter ?? '');
    //               final bChapter = int.tryParse(b.chapter ?? '');
    //               if (aChapter == null || bChapter == null) return 0;
    //               return aChapter.compareTo(bChapter);
    //             },
    //           );
    //           break;
    //       }
    //
    //       break;
    //     case MangaChapterSortOptionEnum.uploadDate:
    //       switch (sortOrder) {
    //         case MangaChapterSortOrderEnum.asc:
    //           processedChapters = chapters?.sorted(
    //             (a, b) {
    //               final aDate = a.readableAt?.asDateTime;
    //               final bDate = b.readableAt?.asDateTime;
    //               if (aDate == null || bDate == null) return 0;
    //               return aDate.compareTo(bDate);
    //             },
    //           );
    //           break;
    //         case MangaChapterSortOrderEnum.desc:
    //           processedChapters = chapters?.sorted(
    //             (a, b) {
    //               final aDate = a.readableAt?.asDateTime;
    //               final bDate = b.readableAt?.asDateTime;
    //               if (aDate == null || bDate == null) return 0;
    //               return -aDate.compareTo(bDate);
    //             },
    //           );
    //           break;
    //       }
    //       break;
    //   }
    // }
  }

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
        authState,
        libraries,
        progress,
        parameter,
        hasNextPage,
        isPagingNextPage,
        sourceUrl,
        prefetchedChapterId,
        histories,
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
    Source? source,
    ChapterConfig? config,
    AuthState? authState,
    List<Manga>? libraries,
    Set<String>? prefetchedChapterId,
    Map<DownloadChapterKey, DownloadChapterProgress>? progress,
    SearchChapterParameter? parameter,
    bool? hasNextPage,
    bool? isPagingNextPage,
    ValueGetter<String?>? sourceUrl,
    Map<num, Chapter>? histories,
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
      authState: authState ?? this.authState,
      libraries: libraries ?? this.libraries,
      progress: progress ?? this.progress,
      parameter: parameter ?? this.parameter,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      sourceUrl: sourceUrl != null ? sourceUrl() : this.sourceUrl,
      prefetchedChapterId: prefetchedChapterId ?? this.prefetchedChapterId,
      histories: histories ?? this.histories,
    );
  }
}
