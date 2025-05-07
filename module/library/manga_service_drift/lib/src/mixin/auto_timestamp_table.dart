import 'package:drift/drift.dart';

mixin AutoTimestampTable on Table {
  TextColumn get createdAt => text()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
  TextColumn get updatedAt => text()
      .named('updated_at')
      .clientDefault(() => DateTime.timestamp().toIso8601String())();
}
