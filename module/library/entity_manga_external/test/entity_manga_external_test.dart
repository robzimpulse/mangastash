import 'package:dart_eval/dart_eval.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityMangaExternalPlugin', () {
    late Runtime runtime;

    setUp(() {
      final compiler = Compiler();
      compiler.addPlugin(EntityMangaExternalPlugin());

      final program = compiler.compile({
        'test_project': {
          'main.dart': '''
            import 'package:entity_manga_external/src/manga_scrapped.dart';
            import 'package:entity_manga_external/src/chapter_scrapped.dart';
            import 'package:entity_manga_external/src/html_document.dart';

            MangaScrapped createManga() {
              return MangaScrapped(
                id: '1',
                title: 'Test Manga',
                coverUrl: 'https://example.com/cover.jpg',
                author: 'Test Author',
                status: 'Ongoing',
                description: 'Test Description',
                tags: ['Action', 'Adventure'],
                webUrl: 'https://example.com/manga/1',
                createdAt: '2023-01-01',
                updatedAt: '2023-01-02',
              );
            }

            ChapterScrapped createChapter() {
              return ChapterScrapped(
                id: 'c1',
                mangaId: '1',
                title: 'Chapter 1',
                chapter: '1',
                images: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
                webUrl: 'https://example.com/manga/1/chapter/1',
              );
            }
          '''
        }
      });

      runtime = Runtime.ofProgram(program);
      EntityMangaExternalPlugin().configureForRuntime(runtime);
    });

    test('can instantiate and return MangaScrapped from eval', () {
      final result = runtime.executeLib('package:test_project/main.dart', 'createManga');
      expect(result, isA<$MangaScrapped>());
      final manga = (result as $MangaScrapped).$value;
      expect(manga.id, '1');
      expect(manga.title, 'Test Manga');
      expect(manga.tags, ['Action', 'Adventure']);
    });

    test('can instantiate and return ChapterScrapped from eval', () {
      final result = runtime.executeLib('package:test_project/main.dart', 'createChapter');
      expect(result, isA<$ChapterScrapped>());
      final chapter = (result as $ChapterScrapped).$value;
      expect(chapter.id, 'c1');
      expect(chapter.mangaId, '1');
      expect(chapter.images, ['https://example.com/1.jpg', 'https://example.com/2.jpg']);
    });
  });
}
