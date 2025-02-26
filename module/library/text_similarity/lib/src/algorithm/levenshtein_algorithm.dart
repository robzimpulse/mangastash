import 'dart:math';

import 'algorithm.dart';

/// Levenshtein distance is a string metric for measuring the difference between two sequences
class LevenshteinAlgorithm implements Algorithm {

  const LevenshteinAlgorithm();

  /// This ratio transform to percent and distance.
  @override
  double getRatio(List<String> first, List<String> second) {
    if (first == second) {
      return 1.0;
    }

    if (first.isEmpty) {
      return second.length.toDouble();
    }

    if (second.isEmpty) {
      return first.length.toDouble();
    }

    var maxLength = max(first.length, second.length);

    var v0 = List.generate(second.length + 1, (index) => index);
    var v1 = List.filled(second.length + 1, 0);
    List<int> vTemp;

    for (var i = 0; i < first.length; i++) {
      v1[0] = i + 1;
      var minv1 = v1[0];

      // use formula to fill in the rest of the row
      for (var j = 0; j < second.length; j++) {
        var cost = 1;
        if (first[i] == second[j]) {
          cost = 0;
        }
        v1[j + 1] = min(
          v1[j] + 1,
          min(
            v0[j + 1] + 1, // Cost of remove
            v0[j] + cost, // Cost of substitution
          ),
        );

        minv1 = min(minv1, v1[j + 1]);
      }

      if (minv1 >= 99999999) {
        return 99999999;
      }

      vTemp = v0;
      v0 = v1;
      v1 = vTemp;
    }

    return 1.0 - v0.last / maxLength;
  }
}
