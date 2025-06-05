import 'package:drift/drift.dart';

mixin AutoTimestampTable on Table {
  DateTimeColumn get createdAt => dateTime()
      .named('created_at')
      .clientDefault(() => DateTime.timestamp())();
  DateTimeColumn get updatedAt => dateTime()
      .named('updated_at')
      .clientDefault(() => DateTime.timestamp())();
}
