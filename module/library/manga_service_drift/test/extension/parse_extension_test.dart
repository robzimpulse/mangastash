import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/dao/diagnostic_dao.dart';
import 'package:manga_service_drift/src/extension/parse_extension.dart';

void main() {
  final now = DateTime.now();

  group('ParseExtension', () {
    test('duplicatedMangaQuery.parse', () {
      final results = [
        DuplicatedMangaQueryResult(
          id: '1', title: 'Manga A', source: 'Source 1', counter: 2,
          createdAt: now, updatedAt: now,
        ),
        DuplicatedMangaQueryResult(
          id: '2', title: 'Manga A', source: 'Source 1', counter: 2,
          createdAt: now, updatedAt: now,
        ),
      ];
      final parsed = results.parse();
      expect(parsed.length, 1);
      expect(parsed.keys.first.title, 'Manga A');
      expect(parsed.values.first.length, 2);
    });

    test('duplicatedChapterQuery.parse', () {
      final results = [
        DuplicatedChapterQueryResult(
          mangaId: 'm1', mangaTitle: 'Manga A', mangaCreatedAt: now, mangaUpdatedAt: now,
          chapterId: 'c1', chapterNumber: '1', totalDuplicatesFound: 2,
          chapterCreatedAt: now, chapterUpdatedAt: now,
        ),
        DuplicatedChapterQueryResult(
          mangaId: 'm1', mangaTitle: 'Manga A', mangaCreatedAt: now, mangaUpdatedAt: now,
          chapterId: 'c2', chapterNumber: '1', totalDuplicatesFound: 2,
          chapterCreatedAt: now, chapterUpdatedAt: now,
        ),
      ];
      final parsed = results.parse();
      expect(parsed.length, 1);
      expect(parsed.keys.first.chapter, '1');
      expect(parsed.values.first.length, 2);
    });

    test('duplicatedTagQuery.parse', () {
      final results = [
        DuplicatedTagQueryResult(
          id: 1, name: 'Tag A', source: 'Source 1', counter: 2,
          createdAt: now, updatedAt: now,
        ),
        DuplicatedTagQueryResult(
          id: 2, name: 'Tag A', source: 'Source 1', counter: 2,
          createdAt: now, updatedAt: now,
        ),
      ];
      final parsed = results.parse();
      expect(parsed.length, 1);
      expect(parsed.keys.first.name, 'Tag A');
      expect(parsed.values.first.length, 2);
    });

    test('chapterGapQuery.parse', () {
      final results = [
        ChapterGapQueryResult(
          id: 'm1', title: 'Manga A', createdAt: now, updatedAt: now,
          gapStartsAfter: '1', gapEndsAt: '5', missingCountEstimate: 3.0,
        ),
        ChapterGapQueryResult(
          id: 'm1', title: 'Manga A', createdAt: now, updatedAt: now,
          gapStartsAfter: '10', gapEndsAt: '12', missingCountEstimate: 1.0,
        ),
      ];
      final parsed = results.parse();
      expect(parsed.length, 1);
      expect(parsed.first.manga?.title, 'Manga A');
      expect(parsed.first.ranges.length, 2);
    });
  });
}
