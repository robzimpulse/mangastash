import 'dart:typed_data';

import 'package:core_runtime/core_runtime.dart';
import 'package:domain_manga/src/manager/source_manager.dart';
import 'package:domain_manga/src/sources/built_in_source_provider.dart';
import 'package:domain_manga/src/sources/dynamic_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:mocktail/mocktail.dart';

class MockBuiltInSourceProvider extends Mock implements BuiltInSourceProvider {}
class MockDynamicSourceDao extends Mock implements DynamicSourceDao {}
class MockSourceRuntime extends Mock implements SourceRuntime {}
class MockSourceExternal extends Mock implements SourceExternal {}

void main() {
  late MockBuiltInSourceProvider mockBuiltInSourceProvider;
  late MockDynamicSourceDao mockDynamicSourceDao;
  late MockSourceRuntime mockSourceRuntime;

  setUp(() {
    mockBuiltInSourceProvider = MockBuiltInSourceProvider();
    mockDynamicSourceDao = MockDynamicSourceDao();
    mockSourceRuntime = MockSourceRuntime();
  });

  test('should combine built-in and dynamic sources', () async {
    final builtInSource = MockSourceExternal();
    when(() => builtInSource.name).thenReturn('Built-In');
    
    final dynamicSourceDrift = DynamicSourceDrift(
      id: '1',
      name: 'Dynamic',
      baseUrl: 'https://dynamic.com',
      sourceCode: 'code',
      bytecode: Uint8List(0),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    when(() => mockBuiltInSourceProvider.sources).thenReturn([builtInSource]);
    when(() => mockDynamicSourceDao.watchAll()).thenAnswer((_) => Stream.value([dynamicSourceDrift]));

    final sourceManager = SourceManagerImpl(
      builtInSourceProvider: mockBuiltInSourceProvider,
      dynamicSourceDao: mockDynamicSourceDao,
      sourceRuntime: mockSourceRuntime,
    );

    final sources = await sourceManager.watchAllSources().firstWhere((e) => e.isNotEmpty);

    expect(sources.length, 2);
    expect(sources[0].name, 'Built-In');
    expect(sources[1].name, 'Dynamic');
    expect(sources[1], isA<DynamicSourceExternal>());
  });
}
