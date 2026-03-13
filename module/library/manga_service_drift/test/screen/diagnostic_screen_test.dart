import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:manga_service_drift/src/screen/diagnostic_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(executor: MemoryExecutor());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildScreen({
    DiagnosticWidgetBuilder<DuplicatedMangaKey, MangaDrift>? mangaBuilder,
    DiagnosticWidgetBuilder<DuplicatedChapterKey, ChapterDrift>? chapterBuilder,
    DiagnosticWidgetBuilder<DuplicatedTagKey, TagDrift>? tagBuilder,
    DriftWidgetBuilder<ChapterDrift>? orphanChapterBuilder,
    DriftWidgetBuilder<ImageDrift>? orphanImageBuilder,
    DriftWidgetBuilder<IncompleteManga>? chapterGapBuilder,
  }) {
    return MaterialApp(
      home: DiagnosticScreen(
        database: db,
        mangaBuilder: mangaBuilder,
        chapterBuilder: chapterBuilder,
        tagBuilder: tagBuilder,
        orphanChapterBuilder: orphanChapterBuilder,
        orphanImageBuilder: orphanImageBuilder,
        chapterGapBuilder: chapterGapBuilder,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers to seed data
  // ---------------------------------------------------------------------------

  Future<String> insertManga({
    required String id,
    String? title,
    String? source,
    String? webUrl,
  }) async {
    await db
        .into(db.mangaTables)
        .insert(
          MangaTablesCompanion.insert(
            id: Value(id),
            title: Value(title),
            source: Value(source),
            webUrl: Value(webUrl),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return id;
  }

  Future<String> insertChapter({
    required String id,
    String? mangaId,
    String? chapter,
    String? webUrl,
    String? title,
  }) async {
    await db
        .into(db.chapterTables)
        .insert(
          ChapterTablesCompanion.insert(
            id: Value(id),
            mangaId: Value(mangaId),
            chapter: Value(chapter),
            webUrl: Value(webUrl),
            title: Value(title),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return id;
  }

  Future<void> insertTag({
    required String tagId,
    required String name,
    String? source,
  }) async {
    await db
        .into(db.tagTables)
        .insert(
          TagTablesCompanion.insert(
            tagId: Value(tagId),
            name: name,
            source: Value(source),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> insertImage({
    required String id,
    required String chapterId,
    required String webUrl,
    int order = 0,
  }) async {
    await db
        .into(db.imageTables)
        .insert(
          ImageTablesCompanion.insert(
            id: Value(id),
            chapterId: chapterId,
            webUrl: webUrl,
            order: order,
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> scrollToTab(WidgetTester tester, String tabText) async {
    final target = find.text(tabText);
    int retries = 20;
    while (retries > 0) {
      if (tester.any(target)) {
        final center = tester.getCenter(target);
        if (center.dx >= 0 &&
            center.dx <=
                tester.view.physicalSize.width / tester.view.devicePixelRatio) {
          break;
        }
      }
      await tester.drag(find.byType(TabBar), const Offset(-100, 0));
      await tester.pumpAndSettle();
      retries--;
    }
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToTabRaw(WidgetTester tester, String tabText) async {
    final target = find.text(tabText);
    int retries = 20;
    while (retries > 0) {
      if (tester.any(target)) {
        final center = tester.getCenter(target);
        if (center.dx >= 0 &&
            center.dx <=
                tester.view.physicalSize.width / tester.view.devicePixelRatio) {
          break;
        }
      }
      await tester.drag(find.byType(TabBar), const Offset(-100, 0));
      await tester.pump(const Duration(milliseconds: 100));
      retries--;
    }
    await tester.tap(target);
    await tester.pump(const Duration(milliseconds: 500));
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('DiagnosticScreen', () {
    testWidgets('renders and handles all tabs loading/no data', (tester) async {
      await tester.pumpWidget(buildScreen());

      // Initially should show loading (waiting) for the first tab
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('No Data'), findsOneWidget);

      final titles = [
        'Duplicated Manga',
        'Duplicated Chapter',
        'Duplicated Tag',
        'Orphaned Chapter',
        'Orphaned Image',
      ];

      for (final title in titles) {
        await scrollToTab(tester, title);
        await tester.pumpAndSettle();
        expect(find.text('No Data'), findsWidgets);
      }
    });

    testWidgets('Chapter Gap: shows data and custom builder', (tester) async {
      final mangaId = await insertManga(
        id: 'm1',
        title: 'Manga 1',
        source: 'S1',
      );
      await db
          .into(db.libraryTables)
          .insert(LibraryTablesCompanion.insert(mangaId: mangaId));
      await insertChapter(id: 'c1', mangaId: mangaId, chapter: '1');
      await insertChapter(id: 'c3', mangaId: mangaId, chapter: '3');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Manga 1'), findsOneWidget);
      await tester.tap(find.text('Manga 1'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Range: 1 - 3'), findsOneWidget);

      // Custom builder
      await tester.pumpWidget(
        buildScreen(chapterGapBuilder: (m) => Text('GAP:${m.manga?.title}')),
      );
      await tester.pumpAndSettle();
      expect(find.text('GAP:Manga 1'), findsOneWidget);
    });

    testWidgets('Duplicated Manga: shows data and custom builder', (
      tester,
    ) async {
      await insertManga(id: 'm1', title: 'Dup', source: 'S1', webUrl: 'url1');
      await insertManga(id: 'm2', title: 'Dup', source: 'S1', webUrl: 'url2');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Duplicated Manga');

      expect(find.text('Dup'), findsOneWidget);
      await tester.tap(find.text('Dup'));
      await tester.pumpAndSettle();
      expect(find.text('url1'), findsOneWidget);
      expect(find.text('url2'), findsOneWidget);

      // Custom builder
      await tester.pumpWidget(
        buildScreen(mangaBuilder: (e) => Text('MANGA:${e.key.title}')),
      );
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Duplicated Manga');
      expect(find.text('MANGA:Dup'), findsWidgets);
    });

    testWidgets('Duplicated Chapter: shows data and custom builder', (
      tester,
    ) async {
      final mangaId = await insertManga(id: 'm1', title: 'M', source: 'S');
      await insertChapter(id: 'c1', mangaId: mangaId, chapter: '1');
      await insertChapter(id: 'c2', mangaId: mangaId, chapter: '1');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Duplicated Chapter');

      expect(find.text('M'), findsOneWidget);
      await tester.tap(find.text('M'));
      await tester.pumpAndSettle();
      expect(find.text('c1'), findsOneWidget);
      expect(find.text('c2'), findsOneWidget);

      // Custom builder
      await tester.pumpWidget(
        buildScreen(chapterBuilder: (e) => Text('CHAPTER:${e.key.chapter}')),
      );
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Duplicated Chapter');
      expect(find.text('CHAPTER:1'), findsWidgets);
    });

    testWidgets('Duplicated Tag: shows data and custom builder', (
      tester,
    ) async {
      await insertTag(tagId: 't1', name: 'Tag', source: 'S');
      await insertTag(tagId: 't2', name: 'Tag', source: 'S');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Duplicated Tag');

      expect(find.textContaining('Name: Tag'), findsOneWidget);
      await tester.tap(find.textContaining('Name: Tag'));
      await tester.pumpAndSettle();
      expect(find.text('t1'), findsOneWidget);
      expect(find.text('t2'), findsOneWidget);

      // Custom builder
      await tester.pumpWidget(
        buildScreen(tagBuilder: (e) => Text('TAG:${e.key.name}')),
      );
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Duplicated Tag');
      expect(find.text('TAG:Tag'), findsWidgets);
    });

    testWidgets('Orphaned Chapter: shows data and custom builder', (
      tester,
    ) async {
      await insertChapter(
        id: 'c1',
        chapter: '1',
        webUrl: 'url1',
        mangaId: 'ghost',
      );

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Orphaned Chapter');

      expect(find.text('Chapter: 1'), findsOneWidget);
      expect(find.text('Url: url1'), findsOneWidget);

      // Custom builder
      await tester.pumpWidget(
        buildScreen(orphanChapterBuilder: (c) => Text('ORPHAN:${c.id}')),
      );
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Orphaned Chapter');
      expect(find.text('ORPHAN:c1'), findsOneWidget);
    });

    testWidgets('Orphaned Image: shows data and custom builder', (
      tester,
    ) async {
      await insertImage(id: 'i1', chapterId: 'ghost', webUrl: 'url1');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Orphaned Image');

      expect(find.text('Chapter ID: ghost'), findsOneWidget);
      expect(find.text('Source: url1'), findsOneWidget);

      // Custom builder
      await tester.pumpWidget(
        buildScreen(orphanImageBuilder: (i) => Text('IMG:${i.id}')),
      );
      await tester.pumpAndSettle();
      await scrollToTab(tester, 'Orphaned Image');
      expect(find.text('IMG:i1'), findsOneWidget);
    });

    testWidgets('handles stream errors across all tabs', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Force SQL errors by dropping tables
      await db.customStatement('DROP TABLE manga_tables;');
      await db.customStatement('DROP TABLE chapter_tables;');
      await db.customStatement('DROP TABLE tag_tables;');
      await db.customStatement('DROP TABLE image_tables;');
      await db.customStatement('DROP TABLE library_tables;');

      final titles = [
        'Chapter Gap',
        'Duplicated Manga',
        'Duplicated Chapter',
        'Duplicated Tag',
        'Orphaned Chapter',
        'Orphaned Image',
      ];
      for (final title in titles) {
        await scrollToTabRaw(tester, title);
        for (int i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pump(const Duration(milliseconds: 500));
        // We expect an error text to appear.
        expect(find.byType(Text), findsWidgets);
      }
    });

    testWidgets('delete action works', (tester) async {
      // Seed duplicates
      await insertManga(id: 'm1', title: 'D', source: 'S');
      await insertManga(id: 'm2', title: 'D', source: 'S');
      final mid = await insertManga(id: 'm3', title: 'X', source: 'S');
      await insertChapter(id: 'c1', mangaId: mid, chapter: '1');
      await insertChapter(id: 'c2', mangaId: mid, chapter: '1');
      await insertTag(tagId: 't1', name: 'T', source: 'S');
      await insertTag(tagId: 't2', name: 'T', source: 'S');
      await insertChapter(id: 'oc', mangaId: 'ghost', chapter: '2');
      await insertImage(id: 'oi', chapterId: 'ghost', webUrl: 'u');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify database is cleaned
      expect(find.text('No Data'), findsOneWidget);
    });
  });
}
