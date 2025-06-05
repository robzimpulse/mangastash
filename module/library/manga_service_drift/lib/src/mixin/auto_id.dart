import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

mixin AutoTextIdTable on Table {
  TextColumn get id =>
      text().named('id').clientDefault(() => const Uuid().v4())();
}

mixin AutoIntegerIdTable on Table {
  IntColumn get id => integer().named('id').autoIncrement()();
}
