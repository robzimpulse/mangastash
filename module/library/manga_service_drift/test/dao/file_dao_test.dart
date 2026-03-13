import 'dart:convert';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String path;
  MockPathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late AppDatabase db;
  late FileDao dao;
  late FileSystem fs;

  setUp(() async {
    fs = const LocalFileSystem();
    final tempDir = await fs.systemTempDirectory.createTemp('mock_support_dir');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
    db = AppDatabase(executor: MemoryExecutor());
    dao = FileDao(db);
    
    // Create the AppDatabase directory to prevent OS Error: No such file or directory inside FileDao.directory()
    await (await db.databaseDirectory()).create(recursive: true);
  });

  tearDown(() => db.close());

  group('File Dao Test', () {
    test('addFromFile, file, and search', () async {
      // Create mock file
      final tempDir = await fs.systemTempDirectory.createTemp('test_in');
      final input = tempDir.childFile('image.png');
      await input.writeAsBytes(utf8.encode('mock_image_data'));

      final added = await dao.addFromFile(
        webUrl: 'http://test.com/image.png',
        file: input,
      );

      final searchResult = await dao.search(webUrls: ['http://test.com/image.png']);
      expect(searchResult.length, 1);
      final retrievedFileRecord = searchResult.first;
      expect(retrievedFileRecord.id, added.id);
      
      // Test `file()` checks file existence
      final loadedFile = await dao.file(retrievedFileRecord, checkFile: true);
      expect(await loadedFile.exists(), isTrue);
      expect(await loadedFile.readAsString(), 'mock_image_data');

      // Test searching by id
      final searchById = await dao.search(ids: [added.id]);
      expect(searchById.length, 1);
      
      // Test searching by relativePath
      final searchByPath = await dao.search(relativePaths: [added.relativePath]);
      expect(searchByPath.length, 1);
    });

    test('file throws FileSystemException when not exists and checkFile true', () async {
      final tempDir = await fs.systemTempDirectory.createTemp('test_in');
      final input = tempDir.childFile('image2.png');
      await input.writeAsBytes(utf8.encode('data'));

      final added = await dao.addFromFile(
        webUrl: 'http://test.com/image2.png',
        file: input,
      );
      
      // Manually delete the saved file from memory system
      final directory = await dao.directory();
      final destination = directory.childFile(added.relativePath);
      await destination.delete();

      try {
        await dao.file(added, checkFile: true);
        fail('Should throw exception');
      } on FileSystemException catch (e) {
        expect(e.message, contains('File not found'));
      }
      
      // It should also remove the record from DB
      final searchResult = await dao.search(ids: [added.id]);
      expect(searchResult.isEmpty, isTrue);
    });

    test('sync cleans orphaned db records and orphaned files', () async {
      final tempDir = await fs.systemTempDirectory.createTemp('test_in');
      final input = tempDir.childFile('image3.png');
      await input.writeAsBytes(utf8.encode('data'));

      // 1. Add valid
      final addedValid = await dao.addFromFile(
        webUrl: 'http://test.com/image3.png',
        file: input,
      );
      
      // 2. Add orphaned db record
      final addedOrphan = await dao.addFromFile(
        webUrl: 'http://test.com/image4.png',
        file: input,
      );
      final destOrphan = (await dao.directory()).childFile(addedOrphan.relativePath);
      await destOrphan.delete(); // Make file missing
      
      // 3. Add orphaned file
      final dir = await dao.directory();
      final orphanFile = dir.childFile('unknown.png');
      await orphanFile.writeAsBytes(utf8.encode('unknown'));
      expect(await orphanFile.exists(), isTrue);

      await dao.sync();

      // Ensure valid record is kept
      expect((await dao.search(ids: [addedValid.id])).length, 1);
      
      // Ensure orphaned db record is gone
      expect((await dao.search(ids: [addedOrphan.id])).isEmpty, isTrue);

      // Ensure orphaned file is gone
      expect(await orphanFile.exists(), isFalse);
    });

    test('remove', () async {
      final tempDir = await fs.systemTempDirectory.createTemp('test_in');
      final input = tempDir.childFile('image_del.png');
      await input.writeAsBytes(utf8.encode('data'));

      final added = await dao.addFromFile(
        webUrl: 'http://test.com/image_del.png',
        file: input,
      );

      final returned = await dao.remove(ids: [added.id]);
      expect(returned.length, 1);
      expect(returned.first.id, added.id);
      
      final searchResult = await dao.search(ids: [added.id]);
      expect(searchResult.isEmpty, isTrue);
    });
  });
}
