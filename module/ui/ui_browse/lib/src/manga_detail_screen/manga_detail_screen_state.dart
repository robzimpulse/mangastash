import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:core_environment/core_environment.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

enum DownloadOption {
  next('Next Chapter'),
  next5('Next 5 Chapter'),
  next10('Next 10 Chapter'),
  custom('Custom'),
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
  final List<MangaChapter>? chapters;
  final MangaSourceEnum? sourceEnum;
  final AuthState? authState;
  final List<Manga> libraries;
  final Map<DownloadChapterKey, DownloadChapterProgress>? progress;

  final MangaChapterConfig config;
  final SearchChapterParameter parameter;
  final bool hasNextPage;
  final bool isPagingNextPage;
  final String? sourceUrl;

  late final List<String> chapterIds;
  late final Set<num> chaptersKey;
  late final Map<num, MangaChapter> processedChapters;
  late final int totalChapter;
  late final bool isOnLibrary;

  MangaDetailScreenState({
    this.isLoadingManga = false,
    this.isLoadingChapters = false,
    this.errorManga,
    this.errorChapters,
    this.mangaId,
    this.manga,
    this.chapters,
    this.sourceEnum,
    this.config = const MangaChapterConfig(),
    this.authState,
    this.libraries = const [],
    this.progress,
    this.parameter = const SearchChapterParameter(),
    this.hasNextPage = false,
    this.isPagingNextPage = false,
    this.sourceUrl,
  }) {
    isOnLibrary = libraries.firstWhereOrNull((e) => e.id == mangaId) != null;

    final Map<num, MangaChapter> processedChapters = {};
    final List<String> chapterIds = [];

    for (final data in chapters ?? <MangaChapter>[]) {
      final chapter = data.numChapter;

      if (chapter != null) {
        processedChapters.update(
          chapter,
          (value) {
            final oldDate = value.publishAt?.asDateTime;
            final newDate = data.publishAt?.asDateTime;

            if (oldDate == null) {
              return data;
            }

            if (newDate == null) {
              return value;
            }

            return newDate.isBefore(oldDate) ? value : data;
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

    this.chapterIds = chapterIds;

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
        sourceEnum,
        config,
        authState,
        libraries,
        progress,
        parameter,
        hasNextPage,
        isPagingNextPage,
        sourceUrl,
      ];

  MangaDetailScreenState copyWith({
    bool? isLoadingManga,
    bool? isLoadingChapters,
    ValueGetter<Exception?>? errorChapters,
    ValueGetter<Exception?>? errorManga,
    String? mangaId,
    Manga? manga,
    List<MangaChapter>? chapters,
    String? sourceId,
    MangaSourceEnum? sourceEnum,
    MangaChapterConfig? config,
    AuthState? authState,
    List<Manga>? libraries,
    Map<DownloadChapterKey, DownloadChapterProgress>? progress,
    SearchChapterParameter? parameter,
    bool? hasNextPage,
    bool? isPagingNextPage,
    ValueGetter<String?>? sourceUrl,
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
      sourceEnum: sourceEnum ?? this.sourceEnum,
      authState: authState ?? this.authState,
      libraries: libraries ?? this.libraries,
      progress: progress ?? this.progress,
      parameter: parameter ?? this.parameter,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPagingNextPage: isPagingNextPage ?? this.isPagingNextPage,
      sourceUrl: sourceUrl != null ? sourceUrl() : this.sourceUrl,
    );
  }
}
