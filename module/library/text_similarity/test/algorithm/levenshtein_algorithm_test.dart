import 'package:flutter_test/flutter_test.dart';
import 'package:text_similarity/src/algorithm/levenshtein_algorithm.dart';
import 'package:text_similarity/src/base/string_matcher.dart';
import 'package:text_similarity/src/enum/term_enum.dart';

void main() {
  group('Levenshtein', () {
    final levenshteinChar = StringMatcher(
      term: TermEnum.char,
      algorithm: LevenshteinAlgorithm(),
    );

    final levenshteinWord = StringMatcher(
      term: TermEnum.word,
      algorithm: LevenshteinAlgorithm(),
      separators: [' ', ','],
    );

    test('Supports types test', () {
      try {
        levenshteinChar.similar(null, 'w1')?.ratio;
      } catch (e) {
        expect(e.runtimeType, UnsupportedError);
      }
    });

    group('Char', () {
      test('Similar ratio test', () {
        expect(levenshteinChar.similar('test1', 'test1')?.ratio, 1);
      });

      test('Empty values', () {
        expect(levenshteinChar.similar('', 't')?.ratio, 1);
      });
    });

    group('Word', () {
      test('Ratio test', () {
        expect(
          levenshteinWord.similar('word test', 'word test')?.ratio,
          1,
        );
      });
      test('Percent test', () {
        expect(
          levenshteinWord.similar('word test', 'word test')?.percent,
          100,
        );
      });

      test('Different characters', () {
        expect(
          levenshteinWord.similar('word,test', 'word test')?.percent,
          100,
        );
      });
    });

    group('Partial similar', () {
      var word = 'fuzzy';
      var listWords = <String>[
        'anime',
        'spider',
        'dart_best_language',
        'fuzzy'
      ];

      test('Limit more than elements in list', () {
        expect(
          levenshteinChar
              .partialSimilarOne(
                word,
                listWords,
                (a, b) => a.ratio.compareTo(b.ratio),
                selector: (el) => el.ratio,
              )
              .$2,
          1,
        );
      });

      test('Check limit', () {
        expect(
          levenshteinChar.partialSimilar(
            word,
            listWords,
            (a, b) => a.ratio.compareTo(b.ratio),
            selector: (el) => el.ratio,
            limit: 1,
          ),
          [('fuzzy', 1.0)],
        );
      });

      // TODO: Testing for different terms: ngram and word. (partialSimilar/partialSimilarOne)
    });
  });
}
