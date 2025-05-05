import 'package:drift/drift.dart';

import '../database/database.dart';

class MangaDrift implements Insertable<MangaDrift> {
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final String? webUrl;
  final String? source;
  final String? createdAt;
  final String? updatedAt;

  /// TODO: add tags
  const MangaDrift({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.webUrl,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return MangaTablesCompanion(
      id: id == null ? const Value.absent() : Value(id),
      title: title == null ? const Value.absent() : Value(title),
      coverUrl: coverUrl == null ? const Value.absent() : Value(coverUrl),
      author: author == null ? const Value.absent() : Value(author),
      status: status == null ? const Value.absent() : Value(status),
      description:
          description == null ? const Value.absent() : Value(description),
      webUrl: webUrl == null ? const Value.absent() : Value(webUrl),
      source: source == null ? const Value.absent() : Value(source),
      updatedAt: Value(DateTime.now().toIso8601String()),
    ).toColumns(false);
  }
}
