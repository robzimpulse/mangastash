import 'package:mocktail/mocktail.dart';
import 'package:universal_io/universal_io.dart';

class FakeDirectory extends Mock implements Directory {
  FakeDirectory() {
    when(() => path).thenReturn('fake/directory/');
    when(() => exists()).thenAnswer((_) async => true);
    when(
      () => create(recursive: any(named: 'recursive')),
    ).thenAnswer((_) async => this);
    when(() => uri).thenReturn(Uri.file('fake/directory/'));
  }
}
