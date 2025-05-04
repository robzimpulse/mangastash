import 'package:drift/drift.dart';

class MangaTables extends Table {

  TextColumn get id => text().named('id').nullable().call();

  TextColumn get title => text().named('title').nullable().call();

  TextColumn get coverUrl => text().named('cover_url').nullable().call();

  TextColumn get author => text().named('author').nullable().call();

  TextColumn get status => text().named('status').nullable().call();

  TextColumn get description => text().named('description').nullable().call();

  TextColumn get webUrl => text().named('webUrl').nullable().call();

  TextColumn get source => text().named('source').nullable().call();

  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())
      .call();
}
