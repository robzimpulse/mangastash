class StringMatcherValue {
  final double _ratio;
  final int _maxLength;

  double get ratio => _ratio;

  int get distance => ((1.0 - _ratio) * _maxLength).ceil();

  double get percent => _ratio * 100.0;

  StringMatcherValue({required double ratio, required int maxLength})
      : _ratio = ratio,
        _maxLength = maxLength;
}
