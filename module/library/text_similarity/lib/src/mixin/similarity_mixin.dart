import 'package:collection/collection.dart';

import '../algorithm/algorithm.dart';
import '../algorithm/levenshtein_algorithm.dart';
import '../base/string_matcher.dart';
import '../enum/term_enum.dart';

mixin SimilarityMixin implements Comparable {
  List<Object?> get similarProp;

  double similarity(
    SimilarityMixin other, {
    TermEnum term = TermEnum.char,
    Algorithm algorithm = const LevenshteinAlgorithm(),
  }) {
    if (similarProp.length != other.similarProp.length) return 0;
    final matcher = StringMatcher(term: term, algorithm: algorithm);
    final scores = <double>[];
    for (final val in IterableZip([similarProp, other.similarProp])) {
      final current = val.firstOrNull;
      final other = val.lastOrNull;
      if (other is SimilarityMixin && current is SimilarityMixin) {
        scores.add(current.similarity(other, term: term, algorithm: algorithm));
      }
      if (other is List<String> && current is List<String>) {
        scores.add(matcher.similar(current, other)?.ratio ?? 0);
      }
      if (other is String && current is String) {
        scores.add(matcher.similar(current, other)?.ratio ?? 0);
      }
    }
    return scores.average;
  }

  @override
  int compareTo(other) {
    return (similarity(other) * 1000).toInt();
  }
}
