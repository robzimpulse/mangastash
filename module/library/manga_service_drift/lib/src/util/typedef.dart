import 'dart:async';

typedef LoggerCallback =
    void Function(
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
