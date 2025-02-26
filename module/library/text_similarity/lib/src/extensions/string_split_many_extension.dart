import 'dart:math';

extension StringSplitMany on String {
  List<String> splitMany(List<String> splitters) {
    if (splitters.any((element) => element.length > 1)) {
      throw ArgumentError('Each separator must consist of a single character');
    }

    var result = <String>[];
    var startIndex = 0;
    var changedIndex = false;

    for (var i = 0; i < length; i++) {
      if (splitters.contains(this[i])) {
        changedIndex = true;
        result.add(substring(startIndex, i));
        startIndex = i + 1;
      }
    }

    // For last element
    if (changedIndex) {
      result.add(substring(startIndex));
    }

    return result;
  }

  String _subReplacer(
    int firstIndex,
    bool isReplacePunctuationsOnSpace,
    List<String> splitters, [
    int? endIndex,
  ]) {
    var sub = endIndex == null
        ? substring(firstIndex)
        : substring(firstIndex, endIndex);
    if (isReplacePunctuationsOnSpace) {
      for (var sign in splitters) {
        sub = sub.replaceAll(sign, ' ');
      }
    }
    return sub;
  }

  List<String> ngramSplit(
    List<String> splitters,
    int ngramValue, [
    bool isReplacePunctuationsOnSpace = false,
  ]) {
    if (splitters.any((element) => element.length > 1)) {
      throw ArgumentError('Each separator must consist of a single character');
    }

    var result = <String>[];
    var startIndex = 0;
    var firstStartIndex = 0;
    var currentCountNgram = 0;
    var changedIndex = false;

    for (var i = 0; i < length; i++) {
      if (splitters.contains(this[i])) {
        if (currentCountNgram == 0) {
          firstStartIndex = i + 1;
          changedIndex = true;
        }
        currentCountNgram++;
        if (currentCountNgram == ngramValue) {
          result.add(
            _subReplacer(
              startIndex,
              isReplacePunctuationsOnSpace,
              splitters,
              i,
            ),
          );
          startIndex = i + 1;
          currentCountNgram = 0;
        }
      }
    }

    // For last element
    if (changedIndex) {
      var minIndex = min(startIndex, firstStartIndex);
      var sub = _subReplacer(minIndex, isReplacePunctuationsOnSpace, splitters);
      result.add(sub);
    }

    return result;
  }
}
