import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../database/database.dart';
import '../extension/value_or_null_extension.dart';

class MangaTagDrift extends Equatable {
  final String? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  const MangaTagDrift({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory MangaTagDrift.fromCompanion(MangaTagTablesCompanion tag) {
    return MangaTagDrift(
      id: tag.id.valueOrNull,
      name: tag.name.valueOrNull,
      createdAt: tag.createdAt.valueOrNull,
      updatedAt: tag.updatedAt.valueOrNull,
    );
  }

  MangaTagTablesCompanion toCompanion() {
    return MangaTagTablesCompanion(
      createdAt: Value.absentIfNull(createdAt),
      updatedAt: Value.absentIfNull(updatedAt),
      id: Value.absentIfNull(id),
      name: Value.absentIfNull(name),
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}