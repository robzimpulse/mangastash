import 'package:json_annotation/json_annotation.dart';

@Deprecated('This will be deprecated')
enum MangaSourceEnum {
  @JsonValue("Manga Dex")
  mangadex('Manga Dex'),
  @JsonValue("Asura Scans")
  asurascan('Asura Scans'),
  @JsonValue("Manga Clash")
  mangaclash('Manga Clash');

  final String value;

  const MangaSourceEnum(this.value);

  factory MangaSourceEnum.fromValue(String? value) {
    return MangaSourceEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MangaSourceEnum.mangadex,
    );
  }
}
