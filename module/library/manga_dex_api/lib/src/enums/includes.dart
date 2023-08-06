enum Include {
  coverArt('cover_art'),
  author('author'),
  artist('artist'),
  tag('tag'),
  creator('creator');

  final String rawValue;

  const Include(this.rawValue);
}
