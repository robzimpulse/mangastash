import 'dart:async';

import 'package:equatable/equatable.dart';

class LogModel extends Equatable {
  final String message;
  final Map<String, dynamic>? extra;
  final DateTime? time;
  final int? sequenceNumber;
  final int level;
  final String? name;
  final Zone? zone;
  final Object? error;
  final StackTrace? stackTrace;

  const LogModel({
    required this.message,
    this.time,
    this.extra,
    this.sequenceNumber,
    this.level = 0,
    this.name,
    this.zone,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
        message,
        time,
        extra,
        sequenceNumber,
        level,
        name,
        zone,
        error,
        stackTrace,
      ];
}
