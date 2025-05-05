import 'package:drift/drift.dart';

class MangaChapterTables extends Table {
  TextColumn get id => text().named('id').nullable()();

  TextColumn get mangaId => text().named('manga_id').nullable()();

  TextColumn get mangaTitle => text().named('manga_title').nullable()();

  TextColumn get title => text().named('title').nullable()();

  TextColumn get volume => text().named('volume').nullable()();

  TextColumn get chapter => text().named('chapter').nullable()();

  TextColumn get translatedLanguage =>
      text().named('translated_language').nullable()();

  TextColumn get scanlationGroup =>
      text().named('scanlation_group').nullable()();

  TextColumn get webUrl => text().named('webUrl').nullable()();

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  TextColumn get readableAt => text().named('readable_at').nullable()();

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  TextColumn get publishAt => text().named('publish_at').nullable()();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
}
