import 'package:collection/collection.dart';

enum SourceEnum {
  mangadex(
    name: 'Manga Dex',
    icon: 'https://www.mangadex.org/favicon.ico',
    url: 'https://www.mangadex.org',
  ),
  mangaclash(
    icon: 'https://mangaclash.com/wp-content/uploads/2020/03/cropped-22.jpg',
    name: 'Manga Clash',
    url: 'https://mangaclash.com',
  ),
  asurascan(
    name: 'Asura Scans',
    url: 'https://asurascans.com',
    icon: 'https://asurascans.com/images/logo.webp',
  );

  final String icon;

  final String name;

  final String url;

  const SourceEnum({required this.icon, required this.name, required this.url});

  static SourceEnum? fromName(String name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}
