import 'package:flutter_test/flutter_test.dart';
import 'package:text_similarity/src/extensions/iterable_select_many_extension.dart';
import 'package:text_similarity/src/extensions/string_split_many_extension.dart';

void main() {
  group('Extension methods', () {

    group('Select many', () {
      test('Select: elements % n != 0', () {
        var sList = ['a', 'b', 'c'];
        expect(sList.selectMany(2).toList(), [['a', 'b'], ['c']]);
      });

      test('Select elements more then n', () {
        var sList = ['a', 'b', 'c'];
        try {
          sList.selectMany(666).toList();
        } catch (e) {
          expect(e.runtimeType, ArgumentError);
        }
      });
    });

    group('Split Many', () {
      test('Empty elements', () {
        var splitters = <String>[' ', ','];
        var source = ' a b, c'; // 5 elements

        expect(source.splitMany(splitters), ['', 'a', 'b', '', 'c']);
      });

      test('Empty string', () {
        var splitters = <String>[' ', ','];
        var source = ''; // 0 elements

        expect(source.splitMany(splitters), <String>[]);
      });

      test('Not found matches', () {
        var splitters = <String>[' ', ','];
        var source = 'abcd'; // 0 elements

        expect(source.splitMany(splitters), <String>[]);
      });

      test('Last empty string', () {
        var splitters = <String>[' ', ','];
        var source = 'a b,'; // 3 elements

        expect(source.splitMany(splitters), ['a', 'b', '']);
      });
    });

    group('Ngram Split', () {
      test('Simple Test', () {
        var splitters = <String>[' ', ','];
        var source = 'a b c'; // 2 elements

        expect(source.ngramSplit(splitters, 2), ['a b', 'b c']);
      });

      test('Simple Test 3 ngram', () {
        var splitters = <String>[' ', ','];
        var source = 'a b c d'; // 2 elements

        expect(source.ngramSplit(splitters, 3), ['a b c', 'b c d']);
      });

      test('One element in 3 ngram', () {
        var splitters = <String>[' ', ','];
        var source = 'a b c'; // 1 element

        expect(source.ngramSplit(splitters, 3), ['a b c']);
      });

      test('Replace Signs on space', () {
        var splitters = <String>[' ', ','];
        var source = 'a b,c'; // 2 elements

        expect(source.ngramSplit(splitters, 2, true), ['a b', 'b c']);
      });
    });
  });
}