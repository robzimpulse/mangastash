import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

extension ChapterScrappedExtension on ChapterScrapped {
  Future<Chapter> convert({ConverterCacheManager? manager}) async {
    return Chapter(
      id: id,
      mangaId: mangaId,
      title: title,
      volume: volume,
      chapter: chapter,
      readableAt: await readableAtRaw?.asDateTime(manager: manager),
      publishAt: await publishAtRaw?.asDateTime(manager: manager),
      images: images,
      translatedLanguage: translatedLanguage,
      scanlationGroup: scanlationGroup,
      webUrl: webUrl,
      lastReadAt: await lastReadAtRaw?.asDateTime(manager: manager),
      createdAt: await createdAtRaw?.asDateTime(manager: manager),
      updatedAt: await updatedAtRaw?.asDateTime(manager: manager),
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
