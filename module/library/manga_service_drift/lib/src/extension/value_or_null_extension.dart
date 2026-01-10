import 'package:drift/drift.dart';

extension ValueOrNullExtension<T> on Value<T> {
  T? get valueOrNull => present ? value : null;
}
