import 'package:mocktail/mocktail.dart';
import 'package:universal_io/universal_io.dart';

class FakeFile extends Mock implements File {

  FakeFile() {
    when(() => absolute).thenReturn(this);
    when(() => path).thenReturn('fake_file');
  }
}