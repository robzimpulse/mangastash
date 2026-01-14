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

typedef DuplicatedResult<V> = Map<(String?, String?), List<V>>;
typedef EntryDuplicatedResult<V> = MapEntry<(String?, String?), List<V>>;
typedef DiagnosticWidgetBuilder<V> = Widget? Function(EntryDuplicatedResult<V>);
typedef DriftWidgetBuilder<V> = Widget? Function(V);
