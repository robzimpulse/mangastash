enum TagsMode {
  or('OR'), and('AND');

  final String rawValue;

  const TagsMode(this.rawValue);
}
