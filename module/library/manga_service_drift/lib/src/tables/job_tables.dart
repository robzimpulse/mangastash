import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('JobDrift')
class JobTables extends Table with AutoTimestampTable {
  IntColumn get id => integer().autoIncrement().named('id')();

  TextColumn get type => textEnum<JobType>().named('type')();

  TextColumn get url => text().named('url')();
}

enum JobType {
  manga, chapter, image;
}