import '../database/database.dart';

class MangaTagDrift {
  final String name;
  final String id;
  final String createdAt;

  const MangaTagDrift({
    required this.name,
    required this.id,
    required this.createdAt,
  });

  factory MangaTagDrift.fromDb({required MangaTagTable tag}) {
    return MangaTagDrift(
      id: tag.id,
      name: tag.name,
      createdAt: tag.createdAt,
    );
  }

  MangaTagTable toDb() {
    return MangaTagTable(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }
}
