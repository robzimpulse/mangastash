import 'dart:async';

import 'package:faro/faro.dart';
import 'package:flutter/foundation.dart';

import '../extension/stack_trace_extension.dart';
import 'faro_mixin.dart';

mixin FaroSpanMixin on FaroMixin {
  /// use this function if [body] have any try catch process.
  FutureOr<T> startSpan<T>({
    String? name,
    required FutureOr<T> Function(Span?) body,
    Map<String, String> attributes = const {},
    Span? parentSpan,
  }) async {
    return faro.startSpan(
      name ?? StackTrace.current.callerFunctionName ?? 'Anonymous',
      body,
      attributes: attributes,
      parentSpan: parentSpan,
    );
  }

  /// use this function if [body] don't have any try catch process.
  FutureOr<T> span<T>({
    String? name,
    required FutureOr<T> Function(Span?) body,
    Map<String, String>? attributes,
    Span? parent,
  }) {
    return faro.startSpan<T>(
      name ?? StackTrace.current.callerFunctionName ?? 'Anonymous',
      (span) async {
        try {
          final result = await body.call(span);
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
