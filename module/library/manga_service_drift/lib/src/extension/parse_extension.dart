import 'package:collection/collection.dart';

import '../dao/diagnostic_dao.dart';
import '../database/database.dart';
import '../util/typedef.dart';

extension ParseMangaExtension on List<DuplicatedMangaQueryResult> {
  DuplicatedResult<MangaDrift> parse() {
    return groupListsBy((e) => (e.title, e.source)).map(
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
  DuplicatedResult<ChapterDrift> parse() {
    return groupListsBy((e) => (e.mangaId, e.chapter)).map(
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
  DuplicatedResult<TagDrift> parse() {
    return groupListsBy((e) => (e.name, e.source)).map(
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