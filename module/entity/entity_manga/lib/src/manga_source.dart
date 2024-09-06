import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_source.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaSource extends Equatable {
  final String? iconUrl;

  final MangaSourceEnum? name;

  final String? url;

  final String? id;

  const MangaSource({
    this.iconUrl,
    this.name,
    this.url,
    this.id,
  });

  @override
  List<Object?> get props => [iconUrl, name, url, id];

  factory MangaSource.fromJson(Map<String, dynamic> json) {
    return _$MangaSourceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaSourceToJson(this);

  MangaSource copyWith({
    String? iconUrl,
    MangaSourceEnum? name,
    String? url,
    String? id,
  }) {
    return MangaSource(
      iconUrl: iconUrl ?? this.iconUrl,
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
    );
  }
}

enum MangaSourceEnum {
  @JsonValue("Manga Dex") mangadex('Manga Dex'),
  @JsonValue("Asura Scans") asurascan('Asura Scans');

  final String value;

  const MangaSourceEnum(this.value);
}