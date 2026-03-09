import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

extension MangaScrappedExtension on MangaScrapped {
  Future<Manga> convert({
    required LogBox logbox,
    ConverterCacheManager? manager,
  }) async {
    return Manga(
      id: id,
      title: title,
      coverUrl: coverUrl,
      author: author,
      status: status,
      description: description,
      tags: tags?.map((e) => Tag(name: e)).toList(),
      webUrl: webUrl,
      createdAt: await createdAt?.asDateTime(logbox: logbox, manager: manager),
      updatedAt: await updatedAt?.asDateTime(logbox: logbox, manager: manager),
    );
  }
}

extension ChapterScrappedExtension on ChapterScrapped {
  Future<Chapter> convert({
    required LogBox logbox,
    ConverterCacheManager? manager,
  }) async {
    return Chapter(
      id: id,
      mangaId: mangaId,
      title: title,
      volume: volume,
      chapter: chapter,
      readableAt: await readableAt?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
      publishAt: await publishAt?.asDateTime(logbox: logbox, manager: manager),
      images: images,
      translatedLanguage: translatedLanguage,
      scanlationGroup: scanlationGroup,
      webUrl: webUrl,
      lastReadAt: await lastReadAt?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
      createdAt: await createdAt?.asDateTime(logbox: logbox, manager: manager),
      updatedAt: await updatedAt?.asDateTime(logbox: logbox, manager: manager),
    );
  }
}

extension MangaExtension on Manga {
  Manga adjust() {
    return copyWith(status: toBeginningOfSentenceCase(status?.toLowerCase()));
  }
}

extension TagExtension on Tag {
  Tag adjust() {
    return copyWith(name: toBeginningOfSentenceCase(name?.toLowerCase()));
  }
}
