enum MangaStatus {
  ongoing('ongoing'),
  completed('completed'),
  haitus('haitus'),
  cancelled('cancelled');

  final String rawValue;

  const MangaStatus(this.rawValue);
}
