import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../database/database.dart';

class MangaTagDrift extends Equatable {
  final String? id;
  final String? name;

  const MangaTagDrift({
    this.id,
    this.name,
  });

  factory MangaTagDrift.fromCompanion(MangaTagTablesCompanion tag) {
    return MangaTagDrift(
      id: tag.id.value,
      name: tag.name.value,
    );
  }

  MangaTagTablesCompanion toCompanion() {
    return MangaTagTablesCompanion(
      createdAt: Value(DateTime.now().toIso8601String()),
      updatedAt: Value(DateTime.now().toIso8601String()),
      id: Value.absentIfNull(id),
      name: Value.absentIfNull(name),
    );
  }

  @override
  List<Object?> get props => [id, name];
}