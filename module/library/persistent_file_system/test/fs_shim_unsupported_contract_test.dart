import 'package:file/file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fs_shim_file_system_test.dart' show newTestFileSystem;

void main() {
  late final FileSystem fs;
  late final File file;
  late final Directory directory;

  setUpAll(() {
    fs = newTestFileSystem();
    file = fs.file('/contract/f.txt');
    directory = fs.directory('/contract/d');
  });

  test('File sync members throw UnsupportedError', () {
    expect(file.existsSync, throwsUnsupportedError);
    expect(() => file.createSync(), throwsUnsupportedError);
    expect(() => file.renameSync('/x'), throwsUnsupportedError);
    expect(() => file.copySync('/x'), throwsUnsupportedError);
    expect(file.lengthSync, throwsUnsupportedError);
    expect(file.lastModifiedSync, throwsUnsupportedError);
    expect(file.lastAccessedSync, throwsUnsupportedError);
    expect(
      () => file.setLastModifiedSync(DateTime.now()),
      throwsUnsupportedError,
    );
    expect(
      () => file.setLastAccessedSync(DateTime.now()),
      throwsUnsupportedError,
    );
    expect(file.readAsBytesSync, throwsUnsupportedError);
    expect(file.readAsStringSync, throwsUnsupportedError);
    expect(file.readAsLinesSync, throwsUnsupportedError);
    expect(() => file.writeAsBytesSync([1]), throwsUnsupportedError);
    expect(() => file.writeAsStringSync('x'), throwsUnsupportedError);
    expect(file.statSync, throwsUnsupportedError);
    expect(() => file.deleteSync(), throwsUnsupportedError);
    expect(() => file.openSync(), throwsUnsupportedError);
    expect(file.resolveSymbolicLinksSync, throwsUnsupportedError);
  });

  test('File async-only extras throw UnsupportedError', () {
    expect(() => file.open(), throwsUnsupportedError);
    expect(
      () => file.setLastModified(DateTime.now()),
      throwsUnsupportedError,
    );
    expect(() => file.resolveSymbolicLinks(), throwsUnsupportedError);
    expect(() => file.create(exclusive: true), throwsUnsupportedError);
  });

  test('Directory sync and temp members throw UnsupportedError', () {
    expect(directory.existsSync, throwsUnsupportedError);
    expect(() => directory.createSync(), throwsUnsupportedError);
    expect(() => directory.renameSync('/x'), throwsUnsupportedError);
    expect(() => directory.deleteSync(), throwsUnsupportedError);
    expect(directory.statSync, throwsUnsupportedError);
    expect(() => directory.listSync(), throwsUnsupportedError);
    expect(() => directory.createTempSync(), throwsUnsupportedError);
    expect(() => directory.createTemp(), throwsUnsupportedError);
  });

  test('FileSystem sync members and setters throw UnsupportedError', () {
    expect(() => fs.statSync('/f'), throwsUnsupportedError);
    expect(() => fs.typeSync('/f'), throwsUnsupportedError);
    expect(() => fs.identicalSync('/a', '/b'), throwsUnsupportedError);
    expect(() => fs.identical('/a', '/b'), throwsUnsupportedError);
    expect(() => fs.currentDirectory = '/x', throwsUnsupportedError);
  });

  test('watching is unsupported', () {
    expect(() => file.watch(), throwsUnsupportedError);
    expect(() => directory.watch(), throwsUnsupportedError);
  });

  test('Link sync members throw UnsupportedError', () {
    final link = fs.link('/contract/l');
    expect(link.existsSync, throwsUnsupportedError);
    expect(() => link.createSync('/target'), throwsUnsupportedError);
    expect(() => link.renameSync('/x'), throwsUnsupportedError);
    expect(() => link.deleteSync(), throwsUnsupportedError);
    expect(link.targetSync, throwsUnsupportedError);
  });
}
