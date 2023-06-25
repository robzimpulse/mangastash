enum ContentRating {
  safe('safe'),
  suggestive('suggestive'),
  erotica('erotica'),
  pornographic('pornographic');

  final String rawValue;

  const ContentRating(this.rawValue);
}
