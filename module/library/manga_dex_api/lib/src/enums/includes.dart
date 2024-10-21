enum Include {
  coverArt('cover_art'),
  author('author'),
  artist('artist'),
  tag('tag'),
  creator('creator'),
  scanlationGroup('scanlation_group'),
  manga('manga'),
  user('user');

  final String rawValue;

  const Include(this.rawValue);

  factory Include.fromRawValue(String rawValue) {
    return Include.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => Include.coverArt,
    );
  }
}
