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
            createdAt: e.createdAt,
            updatedAt: e.updatedAt,
            id: e.id,
            mangaId: e.mangaId,
            title: e.title,
            volume: e.volume,
            chapter: e.chapter,
            translatedLanguage: e.translatedLanguage,
            scanlationGroup: e.scanlationGroup,
            webUrl: e.webUrl,
            readableAt: e.readableAt,
            publishAt: e.publishAt,
            lastReadAt: e.lastReadAt,
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

extension ParseIncompleteMangaExtension on List<ChapterGapQueryResult> {
  List<IncompleteManga> parse() {
    final groups = groupListsBy((e) => (e.title, e.source));

    return [
      for (final group in groups.entries)
        IncompleteManga(
          mangaTitle: group.key.$1,
          mangaSource: group.key.$2,
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
