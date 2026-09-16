/// Tests for [DataStorageScreenCubit]: backup writing with rotation,
/// loading-flag safety on failure, and restore state toggling.
import 'dart:typed_data';

import 'package:core_storage/core_storage.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ui_more/src/data_storage_screen/data_storage_screen_cubit.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockGetBackupPathUseCase extends Mock implements GetBackupPathUseCase {}

class _MockDirectory extends Mock implements Directory {}

class _MockFile extends Mock implements File {}

void main() {
  late _MockAppDatabase database;
  late _MockGetBackupPathUseCase getBackupPathUseCase;
  late Directory backupDir;
  late DataStorageScreenCubit cubit;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    database = _MockAppDatabase();
    getBackupPathUseCase = _MockGetBackupPathUseCase();
    backupDir = MemoryFileSystem().directory(
      '/backups',
    )..createSync(recursive: true);
    when(() => getBackupPathUseCase.backupPath).thenReturn(backupDir);
    cubit = DataStorageScreenCubit(
      database: database,
      getBackupPathUseCase: getBackupPathUseCase,
    );
  });

  group('addBackupFromData', () {
    test('writes the backup and prunes the oldest ones past 10 total', () async {
      for (var i = 0; i < 12; i++) {
        backupDir
            .childFile('${1000000000000000 + i}.sqlite')
            .writeAsStringSync('old-$i');
      }
      when(
        () => database.backup(),
      ).thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));

      await cubit.addBackupFromDatabase();

      final names =
          backupDir
              .listSync()
              .whereType<File>()
              .map((file) => file.uri.pathSegments.last)
              .toList()
            ..sort();
      expect(names, hasLength(10));
      expect(names.first, equals('1000000000000003.sqlite'));
      expect(cubit.state.isLoadingBackup, isFalse);
    });

    test('resets isLoadingBackup and rethrows when writing fails', () async {
      final mockDir = _MockDirectory();
      final mockFile = _MockFile();
      when(() => getBackupPathUseCase.backupPath).thenReturn(mockDir);
      when(() => mockDir.childFile(any())).thenReturn(mockFile);
      when(() => mockFile.writeAsBytes(any())).thenThrow(Exception('locked'));

      await expectLater(
        cubit.addBackupFromData(data: Uint8List.fromList([1])),
        throwsA(isA<Exception>()),
      );
      expect(cubit.state.isLoadingBackup, isFalse);
    });
  });

  group('restoreBackup', () {
    Future<File> seedBackupFile() async {
      return backupDir.childFile('1000.sqlite')
        ..writeAsStringSync('restore-me');
    }

    test('restores the file bytes and clears isRestoring when done', () async {
      final file = await seedBackupFile();
      when(() => database.restore(data: any(named: 'data'))).thenAnswer((
        invocation,
      ) async {
        expect(cubit.state.isRestoring, isTrue);
      });

      await cubit.restoreBackup(file);

      final captured =
          verify(
            () => database.restore(data: captureAny(named: 'data')),
          ).captured.single as Uint8List;
      expect(captured, equals(Uint8List.fromList('restore-me'.codeUnits)));
      expect(cubit.state.isRestoring, isFalse);
    });

    test('rethrows and clears isRestoring when the restore fails', () async {
      final file = await seedBackupFile();
      when(
        () => database.restore(data: any(named: 'data')),
      ).thenThrow(Exception('corrupt backup'));

      await expectLater(
        cubit.restoreBackup(file),
        throwsA(isA<Exception>()),
      );
      expect(cubit.state.isRestoring, isFalse);
    });
  });
}
