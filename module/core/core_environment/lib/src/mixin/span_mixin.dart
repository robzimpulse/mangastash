import 'dart:async';

import 'package:faro/faro.dart';
import 'package:flutter/foundation.dart';

import '../extension/stacktrace_extension.dart';

mixin SpanMixin {

  Faro get faro => Faro();

  FutureOr<T> span<T>({
    required AsyncValueGetter<T> process,
    Map<String, String>? attributes,
    Span? parent,
  }) {
    return faro.startSpan<T>(
      StackTrace.current.traces.callerFunctionName,
      (span) async {
        try {
          final result = await process.call();
          span.setStatus(SpanStatusCode.ok);
          return result;
        } catch (e) {
          span.setStatus(SpanStatusCode.error, message: e.toString());
          rethrow;
        } finally {
          span.end();
        }
      },
      attributes: attributes ?? {},
      parentSpan: parent,
    );
  }
}