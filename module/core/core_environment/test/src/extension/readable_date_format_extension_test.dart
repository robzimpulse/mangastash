import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadableDateFormatExtension', () {
    test('readableFormat returns timeago string', () {
      final now = DateTime.now();
      
      // A minute ago
      final oneMinAgo = now.subtract(const Duration(minutes: 1));
      expect(oneMinAgo.readableFormat, contains('a minute ago'));
      
      // In a minute (future)
      final oneMinFuture = now.add(const Duration(minutes: 1));
      // allowFromNow is true, so it should say something like "a minute from now"
      expect(oneMinFuture.readableFormat, contains('a minute from now'));
    });
  });
}
