import 'package:mocktail/mocktail.dart';
import 'package:universal_io/universal_io.dart';

import 'fake_directory.dart';
import 'fake_file.dart';

class FakeIOOverride extends Mock implements IOOverrides {

  FakeIOOverride({required FakeDirectory directory, required FakeFile file}) {
    when(() => createFile(any())).thenReturn(file);
    when(() => createDirectory(any())).thenReturn(directory);
    when(() => getCurrentDirectory()).thenReturn(directory);
  }
}