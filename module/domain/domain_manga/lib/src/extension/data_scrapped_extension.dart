import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

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
      readableAt: await readableAtRaw?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
      publishAt: await publishAtRaw?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
      images: images,
      translatedLanguage: translatedLanguage,
      scanlationGroup: scanlationGroup,
      webUrl: webUrl,
      lastReadAt: await lastReadAtRaw?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
      createdAt: await createdAtRaw?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
      updatedAt: await updatedAtRaw?.asDateTime(
        logbox: logbox,
        manager: manager,
      ),
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
