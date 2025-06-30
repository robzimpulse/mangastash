import 'package:drift/drift.dart';

@DataClassName('DioCacheDrift')
class DioCacheTables extends Table {

  TextColumn get cacheKey => text().named('cache_key')();

  DateTimeColumn get date => dateTime().named('date').nullable()();

  TextColumn get cacheControl => text().named('cache_control').nullable()();

  BlobColumn get content => blob().named('content').nullable()();

  TextColumn get eTag => text().named('e_tag').nullable()();

  DateTimeColumn get expires => dateTime().named('expires').nullable()();

  BlobColumn get headers => blob().named('headers').nullable()();

  TextColumn get lastModified => text().named('last_modified').nullable()();

  DateTimeColumn get maxStale => dateTime().named('max_stale').nullable()();

  IntColumn get priority => integer().named('priority')();

  DateTimeColumn get requestDate => dateTime().named('request_date').nullable()();

  DateTimeColumn get responseDate => dateTime().named('response_date')();

  TextColumn get url => text().named('url')();

  IntColumn get statusCode => integer().named('status_code').nullable()();
}
