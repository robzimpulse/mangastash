import 'dart:collection';
import 'dart:math';

import '../algorithm/algorithm.dart';
import '../enum/term_enum.dart';
import '../extensions/iterable_select_many_extension.dart';
import '../extensions/string_split_many_extension.dart';
import '../model/string_matcher_value.dart';

typedef MatchComparator = int Function(
  StringMatcherValue a,
  StringMatcherValue b,
);
typedef ValueSelector = num Function(StringMatcherValue value);

typedef StringTypeParser = List<String> Function(
  dynamic value,
  TermEnum term,
  List<String> splitters,
  int ngramValue,
);

class StringMatcher {

  final _supportsTypes = <Type, StringTypeParser>{
    String: (value, term, splitters, ngramValue) {
      return switch (term) {
        TermEnum.char => (value as String).split(''),
        TermEnum.word => (value as String).splitMany(splitters),
        TermEnum.ngram => (value as String).ngramSplit(splitters, ngramValue),
      };
    },
    <String>[].runtimeType: (value, term, splitters, ngramValue) {
      return switch (term) {
        TermEnum.char => value as List<String>,
        TermEnum.word => value as List<String>,
        TermEnum.ngram => (value as List<String>)
          ..selectMany(ngramValue)
          ..map((e) => (e as List<String>).join(' ')),
      };
    },
  };

  final int ngramValue;
  final TermEnum term;
  final Algorithm algorithm;
  final List<String> separators;

  /// Constructor are required [term] and [algorithm].
  /// If you choose term ngram, you can also choose [ngramValue] (default 2).
  /// For other terms, such as word and ngram you can chose separators for words (default ' '(space))
  StringMatcher({
    required this.term,
    required this.algorithm,
    this.ngramValue = 2,
    this.separators = const [' '],
  });

  /// Compare [first] and [second] elements and returns
  /// the result as [StringMasterValue], which is wrapper over
  /// values: ratio, percent, distance.
  StringMatcherValue? similar(dynamic first, dynamic second) {

    if (first == null && second == null) {
      return StringMatcherValue(ratio: 1, maxLength: 0);
    }

    final isTypeValid = [
      _supportsTypes.keys.contains(first.runtimeType),
      _supportsTypes.keys.contains(first.runtimeType),
    ].every((e) => e);

    if (!isTypeValid) return null;

    var strings = _parseByTerm(first, second, term, separators, ngramValue);

    final a = strings.$1;
    final b = strings.$2;

    if (a == null || b == null) return null;

    return StringMatcherValue(
      ratio: algorithm.getRatio(a, b),
      maxLength: max(a.length, b.length),
    );
  }

  /// Perform callback functions in [_supportsTypes]
  /// which are mapped to types
  (List<String>?, List<String>?) _parseByTerm(
    dynamic first,
    dynamic second,
    TermEnum term,
    List<String> splitters,
    int ngramValue,
  ) {
    return (
      _supportsTypes[first.runtimeType]?.call(
        first,
        term,
        splitters,
        ngramValue,
      ),
      _supportsTypes[second.runtimeType]?.call(
        second,
        term,
        splitters,
        ngramValue,
      ),
    );
  }

  /// Find best match elements in [secondValues] and sort by [comparator].
  /// Returns the number of elements equal to [limit]
  List<(dynamic, dynamic)> partialSimilar(
    dynamic first,
    Iterable<dynamic> secondValues,
    MatchComparator comparator, {
    int limit = 5,
    ValueSelector? selector,
  }) {
    StringMatcherValue? maxValue;
    var result = ListQueue<(dynamic, StringMatcherValue)>();

    for (final element in secondValues) {
      var strings = _parseByTerm(first, element, term, separators, ngramValue);
      final a = strings.$1;
      final b = strings.$2;

      if (a == null || b == null) continue;

      final matcher = StringMatcherValue(
        ratio: algorithm.getRatio(a, b),
        maxLength: max(a.length, b.length),
      );

      if (maxValue == null) {
        maxValue = matcher;
        result.add((element, maxValue));
        continue;
      }

      if (comparator(matcher, maxValue) == 1) {
        maxValue = matcher;
        result.addFirst((element, matcher));
      } else if (comparator(matcher, maxValue) < 1) {
        result.addLast((element, matcher));
      }
    }

    if (selector != null) {
      return result.take(limit).map((e) => (e.$1, selector(e.$2))).toList();
    }

    return result.take(limit).toList();
  }

  (dynamic, dynamic) partialSimilarOne(
    dynamic first,
    Iterable<dynamic> secondValues,
    MatchComparator comparator, {
    ValueSelector? selector,
  }) {
    dynamic string;
    StringMatcherValue? maxValue;

    for (var element in secondValues) {
      final strings = _parseByTerm(
        first,
        element,
        term,
        separators,
        ngramValue,
      );

      final a = strings.$1;
      final b = strings.$2;

      if (a == null || b == null) continue;

      final matcher = StringMatcherValue(
        ratio: algorithm.getRatio(a, b),
        maxLength: max(a.length, b.length),
      );

      if (maxValue == null) {
        maxValue = matcher;
        string = element;
        continue;
      }
      if (comparator(matcher, maxValue) == 1) {
        maxValue = matcher;
        string = element;
      }
    }

    if (selector != null && maxValue != null) {
      return (string, selector(maxValue));
    }

    return (string, maxValue);
  }
}
