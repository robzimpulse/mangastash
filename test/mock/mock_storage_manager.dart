import 'package:core_storage/core_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageManager extends Mock implements StorageManager {
  MockStorageManager() {
    when(() => clear()).thenAnswer((_) async => {});
    when(() => dispose()).thenAnswer((_) async => {});
  }
}
