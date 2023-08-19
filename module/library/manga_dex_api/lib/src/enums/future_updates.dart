enum FutureUpdates {
  enable('1'),
  disable('2');

  final String rawValue;

  const FutureUpdates(this.rawValue);

  factory FutureUpdates.fromRawValue(String rawValue) {
    return FutureUpdates.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => FutureUpdates.enable,
    );
  }
}
