import 'dart:async';

import 'package:faro/faro.dart';
import 'package:flutter/foundation.dart';

mixin SpanMixin {

  Faro get faro => Faro();

  FutureOr<T> span<T>({
    required AsyncValueGetter<T> process,
    Map<String, String>? attributes,
  }) {
    return faro.startSpan<T>(
      '$runtimeType',
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
    );
  }
}
