enum MangaShelfItemLayout {
  comfortableGrid('Comfortable Grid'),
  compactGrid('Compact Grid'),
  list('List');

  final String rawValue;

  const MangaShelfItemLayout(this.rawValue);

  factory MangaShelfItemLayout.fromRawValue(String rawValue) {
    return MangaShelfItemLayout.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => MangaShelfItemLayout.compactGrid,
    );
  }
}
