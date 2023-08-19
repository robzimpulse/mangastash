enum TagsMode {
  or('OR'),
  and('AND');

  final String rawValue;

  const TagsMode(this.rawValue);

  factory TagsMode.fromRawValue(String rawValue) {
    return TagsMode.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => TagsMode.or,
    );
  }
}
