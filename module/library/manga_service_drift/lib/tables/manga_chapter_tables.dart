import 'package:drift/drift.dart';

class MangaChapterTables extends Table {
  TextColumn get id => text().named('id').nullable().call();

  TextColumn get mangaId => text().named('manga_id').nullable().call();

  TextColumn get mangaTitle => text().named('manga_title').nullable().call();

  TextColumn get title => text().named('title').nullable().call();

  TextColumn get volume => text().named('volume').nullable().call();

  TextColumn get chapter => text().named('chapter').nullable().call();

  TextColumn get translatedLanguage =>
      text().named('translated_language').nullable().call();

  TextColumn get scanlationGroup =>
      text().named('scanlation_group').nullable().call();

  TextColumn get webUrl => text().named('webUrl').nullable().call();

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  TextColumn get readableAt => text().named('readable_at').nullable().call();

  /// must be in ISO8601 Format (yyyy-MM-ddTHH:mm:ss.mmmuuuZ)
  TextColumn get publishAt => text().named('publish_at').nullable().call();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())
      .call();
}
