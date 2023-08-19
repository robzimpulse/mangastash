enum ContentRating {
  safe('safe'),
  suggestive('suggestive'),
  erotica('erotica'),
  pornographic('pornographic');

  final String rawValue;

  const ContentRating(this.rawValue);

  factory ContentRating.fromRawValue(String rawValue) {
    return ContentRating.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => ContentRating.safe,
    );
  }
}
