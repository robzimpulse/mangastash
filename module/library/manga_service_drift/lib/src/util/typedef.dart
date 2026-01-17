import 'dart:async';

import 'package:flutter/cupertino.dart';

typedef LoggerCallback = void Function(
  String message, {
  Map<String, dynamic>? extra,
  DateTime? time,
  int? sequenceNumber,
  int? level,
  String? name,
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
});

typedef EntryDuplicatedResult<K, V> = MapEntry<K, List<V>>;
typedef DiagnosticWidgetBuilder<K, V> = Widget? Function(EntryDuplicatedResult<K, V>);
typedef DriftWidgetBuilder<V> = Widget? Function(V);
