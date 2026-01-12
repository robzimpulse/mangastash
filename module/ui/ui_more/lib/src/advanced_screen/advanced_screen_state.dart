import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';

class AdvancedScreenState extends Equatable {
  const AdvancedScreenState({
    this.duplicatedManga = const {},
    this.isDuplicatedMangaExpanded = false,
    this.duplicatedChapter = const {},
    this.isDuplicatedChapterExpanded = false,
    this.duplicatedTag = const {},
    this.isDuplicatedTagExpanded = false,
    this.orphanedChapter = const [],
    this.isOrphanedExpanded = false,
  });

  final DuplicatedResult<MangaDrift> duplicatedManga;
  final bool isDuplicatedMangaExpanded;

  final DuplicatedResult<ChapterDrift> duplicatedChapter;
  final bool isDuplicatedChapterExpanded;

  final DuplicatedResult<TagDrift> duplicatedTag;
  final bool isDuplicatedTagExpanded;

  final List<ChapterDrift> orphanedChapter;
  final bool isOrphanedExpanded;

  @override
  List<Object?> get props => [
    duplicatedManga,
    isDuplicatedMangaExpanded,
    duplicatedChapter,
    isDuplicatedChapterExpanded,
    duplicatedTag,
    isDuplicatedTagExpanded,
    orphanedChapter,
    isOrphanedExpanded,
  ];

  AdvancedScreenState copyWith({
    DuplicatedResult<MangaDrift>? duplicatedManga,
    bool? isDuplicatedMangaExpanded,
    DuplicatedResult<ChapterDrift>? duplicatedChapter,
    bool? isDuplicatedChapterExpanded,
    DuplicatedResult<TagDrift>? duplicatedTag,
    bool? isDuplicatedTagExpanded,
    List<ChapterDrift>? orphanedChapter,
    bool? isOrphanedExpanded,
  }) {
    return AdvancedScreenState(
      duplicatedManga: duplicatedManga ?? this.duplicatedManga,
      isDuplicatedMangaExpanded:
          isDuplicatedMangaExpanded ?? this.isDuplicatedMangaExpanded,
      duplicatedChapter: duplicatedChapter ?? this.duplicatedChapter,
      isDuplicatedChapterExpanded:
          isDuplicatedChapterExpanded ?? this.isDuplicatedChapterExpanded,
      duplicatedTag: duplicatedTag ?? this.duplicatedTag,
      isDuplicatedTagExpanded:
          isDuplicatedTagExpanded ?? this.isDuplicatedTagExpanded,
      orphanedChapter: orphanedChapter ?? this.orphanedChapter,
      isOrphanedExpanded: isOrphanedExpanded ?? this.isOrphanedExpanded,
    );
  }
}
