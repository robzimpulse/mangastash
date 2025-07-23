import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class Entry {
  final String id;
  final DateTime timestamp;

  Entry({String? id, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.timestamp(),
      id = id ?? const Uuid().v4();

  Widget title(BuildContext context);

  Widget subtitle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      timestamp.toIso8601String(),
      style: textTheme.labelSmall?.copyWith(color: Colors.grey),
    );
  }

  Map<Tab, Widget> tabs(BuildContext context);
}
