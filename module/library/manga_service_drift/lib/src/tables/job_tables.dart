import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('JobDrift')
class JobTables extends Table with AutoTimestampTable {
  IntColumn get id => integer().autoIncrement().named('id')();

  TextColumn get type => textEnum<JobType>().named('type')();

  TextColumn get source => text().named('source')();

  TextColumn get chapterId => text().named('chapter_id').nullable()();

  TextColumn get mangaId => text().named('manga_id').nullable()();
}

enum JobType {
  manga, chapter;
}