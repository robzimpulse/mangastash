import 'dart:async';

import 'package:faro/faro.dart';
import 'package:flutter/foundation.dart';

import '../extension/stack_trace_extension.dart';
import 'faro_mixin.dart';

mixin SpanMixin on FaroMixin {
  /// use this function if [body] have any try catch process.
  FutureOr<T> startSpan<T>(
    String name,
    FutureOr<T> Function(Span?) body, {
    Map<String, String> attributes = const {},
    Span? parentSpan,
  }) async {
    final faro = this.faro;

    if (faro == null) return body.call(null);

    return faro.startSpan(
      name,
      body,
      attributes: attributes,
      parentSpan: parentSpan,
    );
  }

  /// use this function if [body] don't have any try catch process.
  FutureOr<T> span<T>({
    required AsyncValueGetter<T> body,
    Map<String, String>? attributes,
    Span? parent,
  }) {
    final faro = this.faro;

    if (faro == null) return body();

    return faro.startSpan<T>(
      StackTrace.current.callerFunctionName ?? 'Anonymous',
      (span) async {
        try {
          final result = await body.call();
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
