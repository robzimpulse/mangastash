// FakeIOOverride: routes dart:io File/Directory construction to the given
// fakes inside `IOOverrides.runWithIOOverrides` (used by the testScreen
// harness in test/extension/patrol_tester_extension.dart).
//
// Since Dart 3.13 `IOOverrides` is a `base` class, so it can only be
// extended (no longer implemented by a Mock); members not overridden here
// fall back to the default IOOverrides behaviour.
//
// Usage: `FakeIOOverride(directory: FakeDirectory(), file: FakeFile())`.
import 'package:universal_io/universal_io.dart';

import 'fake_directory.dart';
import 'fake_file.dart';

base class FakeIOOverride extends IOOverrides {
  FakeIOOverride({required this._directory, required this._file});

  final FakeDirectory _directory;
  final FakeFile _file;

  @override
  File createFile(String path) => _file;

  @override
  Directory createDirectory(String path) => _directory;

  @override
  Directory getCurrentDirectory() => _directory;
}
