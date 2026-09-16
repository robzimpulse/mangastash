/// Widget tests for DataStorageScreen error surfacing: failed backup and
/// restore actions must show a failure snackbar instead of crashing the
/// handler or reporting success, and an in-flight restore must surface a
/// blocking indicator while it runs.
import 'dart:async';
import 'dart:typed_data';

import 'package:core_storage/core_storage.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_more/src/data_storage_screen/data_storage_screen.dart';
import 'package:ui_more/src/data_storage_screen/data_storage_screen_cubit.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockGetBackupPathUseCase extends Mock implements GetBackupPathUseCase {}

class _MockImagesCacheManager extends Mock implements ImagesCacheManager {}

class _MockFileDao extends Mock implements FileDao {}

class _MockFileSaverUseCase extends Mock implements FileSaverUseCase {}

class _MockFilePickerUseCase extends Mock implements FilePickerUseCase {}

class _MockDirectory extends Mock implements Directory {}

class _MockFile extends Mock implements File {}

void main() {
  late _MockAppDatabase database;
  late _MockGetBackupPathUseCase getBackupPathUseCase;
  late _MockImagesCacheManager imageCacheManager;
  late _MockFileDao fileDao;
  late _MockFileSaverUseCase fileSaverUseCase;
  late _MockFilePickerUseCase filePickerUseCase;
  late Directory backupDir;
  late DataStorageScreenCubit cubit;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    database = _MockAppDatabase();
    getBackupPathUseCase = _MockGetBackupPathUseCase();
    imageCacheManager = _MockImagesCacheManager();
    fileDao = _MockFileDao();
    fileSaverUseCase = _MockFileSaverUseCase();
    filePickerUseCase = _MockFilePickerUseCase();
    backupDir = MemoryFileSystem().directory(
      '/backups',
    )..createSync(recursive: true);
    when(() => getBackupPathUseCase.backupPath).thenReturn(backupDir);
    cubit = DataStorageScreenCubit(
      database: database,
      getBackupPathUseCase: getBackupPathUseCase,
    );
  });

  /// Pumps several frames: ScaffoldScreen's shimmer animates forever, so
  /// [WidgetTester.pumpAndSettle] cannot be used, and animations (tile
  /// expansion, popup menu, snackbar) need an extra frame after finishing.
  Future<void> pumpFrames(WidgetTester tester, {int count = 4}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    final filesDir = MemoryFileSystem().directory(
      '/files',
    )..createSync(recursive: true);
    when(() => fileDao.directory()).thenAnswer((_) async => filesDir);
    when(() => imageCacheManager.getSize()).thenAnswer((_) async => 0);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DataStorageScreenCubit>.value(
          value: cubit,
          child: DataStorageScreen(
            imageCacheManager: imageCacheManager,
            fileSaverUseCase: fileSaverUseCase,
            filePickerUseCase: filePickerUseCase,
            fileDao: fileDao,
            onRestoreBackupConfirmation: () async => true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Backup and Restore'));
    await pumpFrames(tester);
  }

  /// Pumps [DataStorageScreen] on top of a base page on a real route, so the
  /// app bar back button exists and pop-blocking can be exercised.
  Future<void> pumpScreenOnRoute(WidgetTester tester) async {
    final filesDir = MemoryFileSystem().directory(
      '/files',
    )..createSync(recursive: true);
    when(() => fileDao.directory()).thenAnswer((_) async => filesDir);
    when(() => imageCacheManager.getSize()).thenAnswer((_) async => 0);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Center(child: Text('More'))),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<DataStorageScreenCubit>.value(
          value: cubit,
          child: DataStorageScreen(
            imageCacheManager: imageCacheManager,
            fileSaverUseCase: fileSaverUseCase,
            filePickerUseCase: filePickerUseCase,
            fileDao: fileDao,
            onRestoreBackupConfirmation: () async => true,
          ),
        ),
      ),
    );
    await pumpFrames(tester);
    await tester.tap(find.text('Backup and Restore'));
    await pumpFrames(tester);
  }

  testWidgets('in-flight restore shows indicator and blocks back navigation', (
    tester,
  ) async {
    backupDir.childFile('1000.sqlite').writeAsStringSync('backup');
    await cubit.refreshListBackup();
    final restoreDone = Completer<void>();
    when(
      () => database.restore(data: any(named: 'data')),
    ).thenAnswer((_) => restoreDone.future);
    await pumpScreenOnRoute(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await pumpFrames(tester);
    await tester.tap(find.text('Restore'));
    await pumpFrames(tester);

    expect(find.text('Restoring backup data...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await pumpFrames(tester);
    expect(find.text('Data and Storage'), findsOneWidget);

    restoreDone.complete();
    await pumpFrames(tester);

    expect(find.text('Restoring backup data...'), findsNothing);
    expect(find.text('Success restore backup'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await pumpFrames(tester);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Data and Storage'), findsNothing);
  });

  testWidgets('restore failure shows failure snackbar and clears the indicator', (
    tester,
  ) async {
    backupDir.childFile('1000.sqlite').writeAsStringSync('backup');
    await cubit.refreshListBackup();
    when(
      () => database.restore(data: any(named: 'data')),
    ).thenThrow(Exception('corrupt backup'));
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await pumpFrames(tester);
    await tester.tap(find.text('Restore'));
    await pumpFrames(tester);

    expect(find.text('Failed restore backup'), findsOneWidget);
    expect(find.text('Success restore backup'), findsNothing);
    expect(find.text('Restoring backup data...'), findsNothing);
  });

  testWidgets('backup-now failure shows failure snackbar, not success', (
    tester,
  ) async {
    when(() => database.backup()).thenThrow(Exception('locked'));
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await pumpFrames(tester);
    await tester.tap(find.text('From Database'));
    await pumpFrames(tester);

    expect(find.text('Failed adding backup'), findsOneWidget);
    expect(find.text('Success adding backup'), findsNothing);
  });

  testWidgets('external-import failure shows failure snackbar', (tester) async {
    final mockDir = _MockDirectory();
    final mockFile = _MockFile();
    when(() => getBackupPathUseCase.backupPath).thenReturn(mockDir);
    when(() => mockDir.childFile(any())).thenReturn(mockFile);
    when(() => mockFile.writeAsBytes(any())).thenThrow(Exception('locked'));
    when(
      () => filePickerUseCase.execute(
        allowedExtensions: any(named: 'allowedExtensions'),
      ),
    ).thenAnswer((_) async => Uint8List.fromList([1]));
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await pumpFrames(tester);
    await tester.tap(find.text('From File'));
    await pumpFrames(tester);

    expect(find.text('Failed adding backup'), findsOneWidget);
    expect(find.text('Success adding backup'), findsNothing);
  });
}
