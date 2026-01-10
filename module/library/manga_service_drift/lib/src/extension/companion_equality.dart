import 'package:drift/drift.dart';

extension CompanionEquality<T> on UpdateCompanion<T> {
  bool shouldUpdate(UpdateCompanion<T> other) {
    final columns = toColumns(true);
    final otherColumns = other.toColumns(true);

    for (final entry in otherColumns.entries) {
      if (entry.key == 'created_at' || entry.key == 'updated_at') continue;
      if (columns[entry.key] != entry.value) {
        return true;
      }
    }

    return false;
  }
}
