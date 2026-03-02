import 'package:core_environment/core_environment.dart';
import 'package:flutter_test/flutter_test.dart';

enum TestEnum {
  helloWorld,
  fooBar,
  single
}

void main() {
  group('DisplayableEnumExtension', () {
    test('label format is sentence case and title case', () {
      expect(TestEnum.helloWorld.label, equals('Hello World'));
      expect(TestEnum.fooBar.label, equals('Foo Bar'));
      expect(TestEnum.single.label, equals('Single'));
    });

    test('labels formats list of enums', () {
      final list = [TestEnum.helloWorld, TestEnum.single];
      expect(list.labels, equals('Hello World, Single'));
    });
    
    test('labels works on empty list', () {
      final list = <TestEnum>[];
      expect(list.labels, equals(''));
    });
  });
}
