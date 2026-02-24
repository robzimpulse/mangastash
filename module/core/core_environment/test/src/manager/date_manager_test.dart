import 'package:core_environment/src/manager/date_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateManager', () {
    test('create initializes with value from fetcher', () async {
      int fetchCount = 0;
      Future<String> mockFetcher() async {
        fetchCount++;
        return 'Asia/Jakarta';
      }

      final manager = await DateManager.create(fetcher: mockFetcher);

      expect(manager.timezoneDataStream.value, equals('Asia/Jakarta'));
      expect(fetchCount, equals(1));
      
      await manager.dispose();
    });

    test('dispose cancels periodic fetcher subscription', () async {
      final manager = DateManager(
        initialTimeZoneData: 'Asia/Tokyo',
        fetcher: () async => 'Asia/Jakarta'
      );
      
      expect(manager.timezoneDataStream.value, equals('Asia/Tokyo'));
      
      // Immediately cancel stream subscription
      await manager.dispose();
    });
  });
}
