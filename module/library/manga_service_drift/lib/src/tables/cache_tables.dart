import 'package:drift/drift.dart';

import '../mixin/auto_timestamp_table.dart';

@DataClassName('CacheDrift')
class CacheTables extends Table with AutoTimestampTable {

  // /// Internal ID used to represent this cache object
  // final int? id;
  IntColumn get id => integer().autoIncrement().named('id')();

  // /// The URL that was used to download the file
  // final String url;
  TextColumn get url => text().named('url')();

  // /// The key used to identify the object in the cache.
  // ///
  // /// This key is optional and will default to [url] if not specified
  // final String key;
  TextColumn get key => text().named('key')();

  // /// Where the cached file is stored
  // final String relativePath;
  TextColumn get relativePath => text().named('relativePath')();

  // /// eTag provided by the server for cache expiry
  // final String? eTag;
  TextColumn get eTag => text().named('e_tag').nullable()();

  // /// When this cached item becomes invalid
  // final DateTime validTill;
  DateTimeColumn get validTill => dateTime().named('valid_till')();

  // /// When the file is last used
  // final DateTime? touched;
  DateTimeColumn get touched => dateTime().named('touched').nullable()();

  // /// The length of the cached file
  // final int? length;
  IntColumn get length => integer().named('length').nullable()();
}