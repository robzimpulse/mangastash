import 'package:mocktail/mocktail.dart';
import 'package:universal_io/universal_io.dart';

import 'fake_directory.dart';

class FakeIOOverride extends Mock implements IOOverrides {

  FakeIOOverride({required FakeDirectory directory}) {
    when(() => createDirectory(any())).thenReturn(directory);
  }
}