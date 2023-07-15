import 'package:equatable/equatable.dart';

enum MangaSource {
  mangadex(
    iconUrl: 'https://www.mangadex.org/favicon.ico',
    name: 'Manga Dex',
    url: 'https://www.mangadex.org',
  ),
  asurascan(
    iconUrl: 'https://www.asurascans.com/wp-content/uploads/2021/03/cropped-Group_1-1-32x32.png',
    name: 'Asura Scans',
    url: 'https://www.asurascans.com',
  );

  final String iconUrl;
  final String name;
  final String url;

  const MangaSource({
    this.iconUrl = '',
    required this.name,
    required this.url,
  });
}