import 'package:drift/drift.dart';

import '../mixin/auto_id.dart';
import '../mixin/auto_timestamp_table.dart';
import '../util/job_type_enum.dart';

// Indices on chapter_id / manga_id: job_tables had no indices at all, so
// the chapter/manga filters in JobDao's streams and dedup SELECT were full
// table scans (issue #131).
@TableIndex(name: 'idx_job_chapter_id', columns: {#chapterId})
@TableIndex(name: 'idx_job_manga_id', columns: {#mangaId})
@DataClassName('JobDrift')
class JobTables extends Table with AutoTimestampTable, AutoIntegerIdTable {
  TextColumn get type => textEnum<JobTypeEnum>().named('type')();

  TextColumn get source => text().named('source').nullable()();

  TextColumn get chapterId => text().named('chapter_id').nullable()();

  TextColumn get mangaId => text().named('manga_id').nullable()();

  TextColumn get imageUrl => text().named('image_url').nullable()();
}
