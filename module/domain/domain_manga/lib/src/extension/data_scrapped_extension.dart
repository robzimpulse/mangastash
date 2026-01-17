import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

extension MangaScrappedExtension on MangaScrapped {
  Future<Manga> convert({ConverterCacheManager? manager}) async {
    return Manga(
      id: id,
      title: title,
      coverUrl: coverUrl,
      author: author,
      status: status,
      description: description,
      tags: tags?.map((e) => Tag(name: e)).toList(),
      webUrl: webUrl,
      createdAt: await createdAt?.asDateTime(manager: manager),
      updatedAt: await updatedAt?.asDateTime(manager: manager)
    );
  }
}

extension ChapterScrappedExtension on ChapterScrapped {
  Future<Chapter> convert({ConverterCacheManager? manager}) async {
    return Chapter(
      id: id,
      mangaId: mangaId,
      title: title,
      volume: volume,
      chapter: chapter,
      readableAt: await readableAt?.asDateTime(manager: manager),
      publishAt: await publishAt?.asDateTime(manager: manager),
      images: images,
      translatedLanguage: translatedLanguage,
      scanlationGroup: scanlationGroup,
      webUrl: webUrl,
      lastReadAt: await lastReadAt?.asDateTime(manager: manager),
      createdAt: await createdAt?.asDateTime(manager: manager),
      updatedAt: await updatedAt?.asDateTime(manager: manager),
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
