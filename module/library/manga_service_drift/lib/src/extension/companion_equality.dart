import 'package:drift/drift.dart';

extension CompanionEquality<T> on UpdateCompanion<T> {

  bool shouldUpdate(UpdateCompanion<T> other) {
    final columns = toColumns(true);
    final otherColumns = other.toColumns(true);

    bool result = false;

    for (final entry in otherColumns.entries) {
      final value = columns[entry.key];
      final otherValue = entry.value;

      if (value is! Variable) continue;
      if (otherValue is! Variable) continue;

      if (otherValue.value != null || value.value != null) {
        result = result && value.value != otherValue.value;
      }
    }


    return result;
  }

}