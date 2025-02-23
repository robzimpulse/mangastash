import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum/manga_source_enum.dart';

part 'manga_source.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaSource extends Equatable {
  final String? iconUrl;

  final MangaSourceEnum? name;

  final String? url;

  final String? id;

  final bool? crawlable;

  const MangaSource({
    this.iconUrl,
    this.name,
    this.url,
    this.id,
    this.crawlable,
  });

  @override
  List<Object?> get props => [
        iconUrl,
        name,
        url,
        id,
        crawlable,
      ];

  factory MangaSource.fromJson(Map<String, dynamic> json) {
    return _$MangaSourceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaSourceToJson(this);

  MangaSource copyWith({
    String? iconUrl,
    MangaSourceEnum? name,
    String? url,
    String? id,
    bool? crawlable,
  }) {
    return MangaSource(
      iconUrl: iconUrl ?? this.iconUrl,
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
      crawlable: crawlable ?? this.crawlable,
    );
  }
}
