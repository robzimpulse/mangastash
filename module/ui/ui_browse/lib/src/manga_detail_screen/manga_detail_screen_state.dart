import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
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
  final bool isLoading;
  final Exception? error;
  final String? mangaId;
  final Manga? manga;
  final List<MangaChapter>? chapters;
  final MangaSourceEnum? source;
  final MangaChapterConfig? config;
  final AuthState? authState;
  final List<Manga> libraries;

  late final Map<num?, Map<num?, List<MangaChapter>>>? processedChapters;
  late final int? totalChapter;
  late final bool isOnLibrary;

  MangaDetailScreenState({
    this.isLoading = false,
    this.error,
    this.mangaId,
    this.manga,
    this.chapters,
    this.source,
    this.config,
    this.authState,
    this.libraries = const [],
  }) {
    isOnLibrary = libraries.firstWhereOrNull((e) => e.id == mangaId) != null;

    final groupByVolume = chapters
        ?.sortedBy((e) => e.numVolume ?? 0)
        .reversed
        .groupListsBy((e) => e.numVolume);

    final groupByVolumeAndChapter = groupByVolume?.map(
      (key, value) => MapEntry(
        key,
        value
            .sortedBy((e) => e.numChapter ?? 0)
            .reversed
            .groupListsBy((e) => e.numChapter),
      ),
    );
    processedChapters = groupByVolumeAndChapter;
    totalChapter = groupByVolumeAndChapter?.values
        .map((e) => e.values)
        .fold<int>(0, (prev, e) => e.length + prev);

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
        isLoading,
        error,
        mangaId,
        manga,
        chapters,
        source,
        config,
        authState,
        libraries,
      ];

  MangaDetailScreenState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    String? mangaId,
    Manga? manga,
    List<MangaChapter>? chapters,
    String? sourceId,
    MangaSourceEnum? source,
    MangaChapterConfig? config,
    AuthState? authState,
    List<Manga>? libraries,
  }) {
    return MangaDetailScreenState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      source: source ?? this.source,
      authState: authState ?? this.authState,
      libraries: libraries ?? this.libraries,
    );
  }
}
