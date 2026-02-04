import 'package:collection/collection.dart';

import '../dao/diagnostic_dao.dart';
import '../database/database.dart';
import '../model/diagnostic_model.dart';

extension ParseMangaExtension on List<DuplicatedMangaQueryResult> {
  Map<DuplicatedMangaKey, List<MangaDrift>> parse() {
    return groupListsBy(DuplicatedMangaKey.from).map(
      (key, value) => MapEntry(key, [
        ...value.map(
          (e) => MangaDrift(
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            id: e.id,
            title: e.title,
            coverUrl: e.coverUrl,
            author: e.author,
            status: e.status,
            webUrl: e.webUrl,
            description: e.description,
            source: e.source,
          ),
        ),
      ]),
    );
  }
}

extension ParseChapterExtension on List<DuplicatedChapterQueryResult> {
  Map<DuplicatedChapterKey, List<ChapterDrift>> parse() {
    return groupListsBy(DuplicatedChapterKey.from).map(
      (key, value) => MapEntry(key, [
        ...value.map(
          (e) => ChapterDrift(
            createdAt: e.chapterCreatedAt,
            updatedAt: e.chapterUpdatedAt,
            id: e.chapterId,
            mangaId: e.mangaId,
            title: e.chapterTitle,
            volume: e.chapterVolume,
            chapter: e.chapterNumber,
            translatedLanguage: e.chapterTranslatedLanguage,
            scanlationGroup: e.chapterScanlationGroup,
            webUrl: e.chapterWebUrl,
            readableAt: e.chapterReadableAt,
            publishAt: e.chapterPublishAt,
            lastReadAt: e.chapterLastReadAt,
          ),
        ),
      ]),
    );
  }
}

extension ParseTagExtension on List<DuplicatedTagQueryResult> {
  Map<DuplicatedTagKey, List<TagDrift>> parse() {
    return groupListsBy(DuplicatedTagKey.from).map(
      (key, value) => MapEntry(key, [
        ...value.map(
          (e) => TagDrift(
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            id: e.id,
            tagId: e.tagId,
            name: e.name,
            source: e.source,
          ),
        ),
      ]),
    );
  }
}

extension ChapterGapQueryResultToMangaDrift on ChapterGapQueryResult {
  MangaDrift get toMangaDrift {
    return MangaDrift(
      createdAt: createdAt,
      updatedAt: updatedAt,
      id: id,
      title: title,
      coverUrl: coverUrl,
      author: author,
      status: status,
      webUrl: webUrl,
      description: description,
      source: source,
    );
  }
}

extension ParseIncompleteMangaExtension on List<ChapterGapQueryResult> {
  List<IncompleteManga> parse() {
    final groups = groupListsBy((e) => e.toMangaDrift);

    return [
      for (final group in groups.entries)
        IncompleteManga(
          manga: group.key,
          ranges: [
            for (final value in group.value)
              IncompleteMangaRange(
                chapterStart: value.gapStartsAfter,
                chapterEnd: value.gapEndsAt,
                estimatedMissingCount: value.missingCountEstimate,
              ),
          ],
        ),
    ];
  }
}
