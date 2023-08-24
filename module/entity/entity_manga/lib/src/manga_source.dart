import 'package:equatable/equatable.dart';

enum MangaSource {
  mangadex(
    iconUrl: 'https://www.mangadex.org/favicon.ico',
    name: 'Manga Dex',
    url: 'https://www.mangadex.org',
    id: 'manga_dex',
  ),
  asurascans(
    iconUrl:
        'https://www.asurascans.com/wp-content/uploads/2021/03/cropped-Group_1-1-32x32.png',
    name: 'Asura Scans',
    url: 'https://www.asurascans.com',
    id: 'asura_scans',
  );

  final String iconUrl;
  final String name;
  final String url;
  final String id;

  const MangaSource({
    this.iconUrl = '',
    required this.name,
    required this.url,
    required this.id,
  });

  factory MangaSource.fromId(String id) {
    return MangaSource.values.firstWhere(
      (e) => e.id == id,
      orElse: () => MangaSource.mangadex,
    );
  }
}
