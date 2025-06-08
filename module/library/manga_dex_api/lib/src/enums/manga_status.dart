enum MangaStatus {
  ongoing('ongoing'),
  completed('completed'),
  // TODO: rename haitus to hiatus
  haitus('hiatus'),
  cancelled('cancelled');

  final String rawValue;

  const MangaStatus(this.rawValue);

  factory MangaStatus.fromRawValue(String rawValue) {
    return MangaStatus.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => MangaStatus.ongoing,
    );
  }
}
