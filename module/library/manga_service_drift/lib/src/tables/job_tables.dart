import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';
import '../util/job_type_enum.dart';

@DataClassName('JobDrift')
class JobTables extends Table with AutoTimestampTable, AutoIntegerIdTable {
  TextColumn get type => textEnum<JobTypeEnum>().named('type')();

  TextColumn get source => text().named('source').nullable()();

  TextColumn get chapterId => text().named('chapter_id').nullable()();

  TextColumn get mangaId => text().named('manga_id').nullable()();

  TextColumn get imageUrl => text().named('image_url').nullable()();

  TextColumn get path => text().named('path').nullable()();
}
