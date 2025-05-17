import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:text_similarity/text_similarity.dart';

import '../dao/chapter_dao.dart';
import '../dao/manga_dao.dart';
import '../interceptor/log_interceptor.dart';
import '../tables/manga_chapter_image_tables.dart';
import '../tables/manga_chapter_tables.dart';
import '../tables/manga_library_tables.dart';
import '../tables/manga_tables.dart';
import '../tables/manga_tag_relationship_tables.dart';
import '../tables/manga_tag_tables.dart';
import '../util/typedef.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    MangaChapterImageTables,
    MangaChapterTables,
    MangaLibraryTables,
    MangaTables,
    MangaTagTables,
    MangaTagRelationshipTables,
  ],
  daos: [
    MangaDao,
    ChapterDao,
  ],
  include: {
    'drift_file/virtual_manga_table.drift',
    'drift_file/virtual_tag_table.drift',
  },
)
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase({
    QueryExecutor? executor,
    LoggerCallback? logger,
  }) : super(
          LazyDatabase(
            () async => (executor ?? await _openConnection(logger: logger))
              ..interceptWith(LogInterceptor(logger: logger)),
          ),
        );

  @override
  int get schemaVersion => 1;

  Future<void> clear() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  }
}

Future<QueryExecutor> _openConnection({LoggerCallback? logger}) async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }

  return driftDatabase(
    name: 'mangastash-local',
    native: DriftNativeOptions(
      databaseDirectory: () => getApplicationDocumentsDirectory(),
    ),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isEmpty) return;
        logger?.call(
          'Using ${result.chosenImplementation} due to unsupported '
          'browser features: ${result.missingFeatures}',
          name: 'AppDatabase',
        );
      },
    ),
  );
}

extension MangaTablesCompanionSimilarity on MangaTablesCompanion {
  double similarity(MangaTablesCompanion other) {
    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    final score = [
      matcher.similar(title.value, other.title.value)?.ratio ?? 0,
      matcher.similar(coverUrl.value, other.coverUrl.value)?.ratio ?? 0,
      matcher.similar(author.value, other.author.value)?.ratio ?? 0,
      matcher.similar(status.value, other.status.value)?.ratio ?? 0,
      matcher.similar(description.value, other.description.value)?.ratio ?? 0,
      matcher.similar(webUrl.value, other.webUrl.value)?.ratio ?? 0,
      matcher.similar(source.value, other.source.value)?.ratio ?? 0,
    ];

    return score.reduce((a, b) => a + b) / score.length;
  }
}

extension MangaTagTablesCompanionSimilarity on MangaTagTablesCompanion {
  double similarity(MangaTagTablesCompanion other) {
    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    final score = [
      matcher.similar(name.value, other.name.value)?.ratio ?? 0,
    ];

    return score.reduce((a, b) => a + b) / score.length;
  }
}

extension MangaChapterTablesCompanionSimilarity on MangaChapterTablesCompanion {
  double similarity(MangaChapterTablesCompanion other) {
    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    final score = [
      matcher.similar(other.title.value, other.title.value)?.ratio ?? 0,
      matcher.similar(other.volume.value, other.volume.value)?.ratio ?? 0,
      matcher.similar(other.chapter.value, other.chapter.value)?.ratio ?? 0,
      matcher
              .similar(
                other.translatedLanguage.value,
                other.translatedLanguage.value,
              )
              ?.ratio ??
          0,
      matcher
              .similar(other.scanlationGroup.value, other.scanlationGroup.value)
              ?.ratio ??
          0,
      matcher.similar(other.webUrl.value, other.webUrl.value)?.ratio ?? 0,
    ];

    return score.reduce((a, b) => a + b) / score.length;
  }
}
