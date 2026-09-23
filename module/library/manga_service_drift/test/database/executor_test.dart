import 'package:file/local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/executor.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;

  MockPathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('databaseDirectory() exists without pre-creation (#104)', () async {
    const fs = LocalFileSystem();
    final tempDir = await fs.systemTempDirectory.createTemp('executor_test');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
    addTearDown(() => tempDir.delete(recursive: true));

    final directory = await Executor().databaseDirectory();

    // On web the fs_shim backend starts empty: FileDao.directory()'s
    // non-recursive create() only works when this root already exists,
    // matching drift's NativeDatabase which creates missing parents.
    expect(await directory.exists(), isTrue);
    expect(directory.path, endsWith('mangastash-local'));
  });
}
