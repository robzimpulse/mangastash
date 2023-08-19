enum Visibility {
  private('private'),
  public('public');

  final String rawValue;

  const Visibility(this.rawValue);

  factory Visibility.fromRawValue(String rawValue) {
    return Visibility.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => Visibility.private,
    );
  }
}
