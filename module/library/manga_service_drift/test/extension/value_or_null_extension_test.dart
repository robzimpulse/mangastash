import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/extension/value_or_null_extension.dart';

void main() {
  group('ValueOrNullExtension', () {
    test('valueOrNull', () {
      expect(const Value('abc').valueOrNull, 'abc');
      expect(const Value<String>.absent().valueOrNull, isNull);
    });
  });
}
