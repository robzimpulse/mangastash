import 'package:flutter/material.dart';

import '../database/database.dart';
import '../model/diagnostic_model.dart';
import '../screen/diagnostic_screen.dart';
import '../util/typedef.dart';

extension NavigationExtension on AppDatabase {
  void diagnostic({
    required BuildContext context,
    ThemeData? theme,
    DiagnosticWidgetBuilder<DuplicatedMangaKey, MangaDrift>? mangaBuilder,
    DiagnosticWidgetBuilder<DuplicatedChapterKey, ChapterDrift>? chapterBuilder,
    DiagnosticWidgetBuilder<DuplicatedTagKey, TagDrift>? tagBuilder,
    DriftWidgetBuilder<ChapterDrift>? orphanChapterBuilder,
    DriftWidgetBuilder<ImageDrift>? orphanImageBuilder,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'database/diagnostic'),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DiagnosticScreen(
              database: this,
              mangaBuilder: mangaBuilder,
              chapterBuilder: chapterBuilder,
              tagBuilder: tagBuilder,
              orphanChapterBuilder: orphanChapterBuilder,
              orphanImageBuilder: orphanImageBuilder,
            ),
          );
        },
      ),
    );
  }
}
