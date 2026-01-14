import 'package:flutter/material.dart';

import '../dao/chapter_dao.dart';
import '../dao/diagnostic_dao.dart';
import '../dao/image_dao.dart';
import '../dao/manga_dao.dart';
import '../dao/tag_dao.dart';
import '../database/database.dart';
import '../extension/nullable_generic.dart';
import '../util/typedef.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({
    super.key,
    required this.database,
    this.mangaBuilder,
    this.chapterBuilder,
    this.tagBuilder,
    this.orphanChapterBuilder,
    this.orphanImageBuilder,
  });

  final AppDatabase database;

  final DiagnosticWidgetBuilder<MangaDrift>? mangaBuilder;
  final DiagnosticWidgetBuilder<ChapterDrift>? chapterBuilder;
  final DiagnosticWidgetBuilder<TagDrift>? tagBuilder;
  final DriftWidgetBuilder<ChapterDrift>? orphanChapterBuilder;
  final DriftWidgetBuilder<ImageDrift>? orphanImageBuilder;

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late final DiagnosticDao _diagnosticDao = DiagnosticDao(widget.database);
  late final MangaDao _mangaDao = MangaDao(widget.database);
  late final ChapterDao _chapterDao = ChapterDao(widget.database);
  late final TagDao _tagDao = TagDao(widget.database);
  late final ImageDao _imageDao = ImageDao(widget.database);

  late final _menus = <String, WidgetBuilder>{
    'Duplicated Manga': (context) {
      return StreamBuilder(
        stream: _diagnosticDao.duplicateMangaStream,
        builder: (context, snapshot) {
          final data = snapshot.data?.entries;
          final error = snapshot.error;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(child: Text(error.toString()));
          }

          if (data == null || data.isEmpty) {
            return Center(child: Text('No Data'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final value = data.elementAtOrNull(index);
              if (value == null) return null;
              final view = widget.mangaBuilder?.call(value);
              return view?.or(
                ExpansionTile(
                  title: Text('Title: ${value.key.$1}'),
                  subtitle: Text('Source: ${value.key.$2}'),
                  children: [
                    for (final child in value.value)
                      ListTile(title: Text(child.id)),
                  ],
                ),
              );
            },
          );
        },
      );
    },
    'Duplicated Chapter': (context) {
      return StreamBuilder(
        stream: _diagnosticDao.duplicateChapterStream,
        builder: (context, snapshot) {
          final data = snapshot.data?.entries;
          final error = snapshot.error;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(child: Text(error.toString()));
          }

          if (data == null || data.isEmpty) {
            return Center(child: Text('No Data'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final value = data.elementAtOrNull(index);
              if (value == null) return null;
              final view = widget.chapterBuilder?.call(value);
              return view?.or(
                ExpansionTile(
                  title: Text('Manga ID: ${value.key.$1}'),
                  subtitle: Text('Chapter: ${value.key.$2}'),
                  children: [
                    for (final child in value.value)
                      ListTile(title: Text(child.id)),
                  ],
                ),
              );
            },
          );
        },
      );
    },
    'Duplicated Tag': (context) {
      return StreamBuilder(
        stream: _diagnosticDao.duplicateTagStream,
        builder: (context, snapshot) {
          final data = snapshot.data?.entries;
          final error = snapshot.error;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(child: Text(error.toString()));
          }

          if (data == null || data.isEmpty) {
            return Center(child: Text('No Data'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final value = data.elementAtOrNull(index);
              if (value == null) return null;
              final view = widget.tagBuilder?.call(value);
              return view?.or(
                ExpansionTile(
                  title: Text('Name: ${value.key.$1}'),
                  subtitle: Text('Source: ${value.key.$2}'),
                  children: [
                    for (final child in value.value)
                      ListTile(title: Text(child.tagId ?? '-')),
                  ],
                ),
              );
            },
          );
        },
      );
    },
    'Orphaned Chapter': (context) {
      return StreamBuilder(
        stream: _diagnosticDao.orphanChapterStream,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final error = snapshot.error;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(child: Text(error.toString()));
          }

          if (data == null || data.isEmpty) {
            return Center(child: Text('No Data'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final value = data.elementAtOrNull(index);
              if (value == null) return null;
              final view = widget.orphanChapterBuilder?.call(value);
              return view?.or(
                ListTile(
                  title: Text('Chapter: ${value.chapter}'),
                  subtitle: Text('Url: ${value.webUrl}'),
                ),
              );
            },
          );
        },
      );
    },
    'Orphaned Image': (context) {
      return StreamBuilder(
          stream: _diagnosticDao.orphanImageStream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final error = snapshot.error;

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (error != null) {
              return Center(child: Text(error.toString()));
            }

            if (data == null || data.isEmpty) {
              return Center(child: Text('No Data'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final value = data.elementAtOrNull(index);
                if (value == null) return null;
                final view = widget.orphanImageBuilder?.call(value);
                return view?.or(
                  ListTile(
                    title: Text('Chapter ID: ${value.chapterId}'),
                    subtitle: Text('Source: ${value.webUrl}'),
                  ),
                );
              },
            );
          });
    }
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _menus.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Diagnostic'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [..._menus.entries.map((e) => Tab(text: e.key))],
          ),
          actions: [
            IconButton(
              onPressed: () async {
                final mangas = await _diagnosticDao.duplicateManga.then(
                  (e) => e.values.expand((e) => e.map((e) => e.id)),
                );

                await _mangaDao.remove(ids: [...mangas]);

                final chapters = await _diagnosticDao.duplicateChapter.then(
                  (e) => e.values.expand((e) => e.map((e) => e.id)),
                );

                await _chapterDao.remove(ids: [...chapters]);

                final tags = await _diagnosticDao.duplicateTag.then(
                  (e) => e.values.expand((e) => e.map((e) => e.id)),
                );

                await _tagDao.remove(ids: [...tags]);

                final orphanChapter = await _diagnosticDao.orphanChapter.then(
                  (e) => e.map((e) => e.id),
                );

                await _chapterDao.remove(ids: [...orphanChapter]);

                final orphanImage = await _diagnosticDao.orphanImage.then(
                  (e) => e.map((e) => e.id),
                );

                await _imageDao.remove(ids: [...orphanImage]);
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: TabBarView(
          children: [..._menus.entries.map((e) => e.value(context))],
        ),
      ),
    );
  }
}
