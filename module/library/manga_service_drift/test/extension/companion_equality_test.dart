import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/database.dart';
import 'package:manga_service_drift/src/extension/companion_equality.dart';

void main() {
  group('CompanionEquality', () {
    test('should return true when columns are different', () {
      const c1 = MangaTablesCompanion(title: Value('title1'));
      const c2 = MangaTablesCompanion(title: Value('title2'));
      expect(c1.shouldUpdate(c2), isTrue);
    });

    test('should return false when columns are same', () {
      const c1 = MangaTablesCompanion(title: Value('title1'));
      const c2 = MangaTablesCompanion(title: Value('title1'));
      expect(c1.shouldUpdate(c2), isFalse);
    });

    test('should ignore created_at and updated_at', () {
      final now = DateTime.now();
      final c1 = MangaTablesCompanion(
        title: const Value('title1'),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      final c2 = MangaTablesCompanion(
        title: const Value('title1'),
        createdAt: Value(now.add(const Duration(seconds: 1))),
        updatedAt: Value(now.add(const Duration(seconds: 1))),
      );
      expect(c1.shouldUpdate(c2), isFalse);
    });
  });
}
