import 'package:uuid/uuid.dart';

abstract class Entry {
  final String id;
  final DateTime timestamp;

  Entry({String? id, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.timestamp(),
      id = id ?? const Uuid().v4();
}
