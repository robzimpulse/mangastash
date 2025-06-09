import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import 'enum/manga_source_enum.dart';

part 'source.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Source extends Equatable {
  final String? iconUrl;

  final MangaSourceEnum? name;

  final String? url;

  final String? id;

  const Source({
    this.iconUrl,
    this.name,
    this.url,
    this.id,
  });

  @override
  List<Object?> get props => [
        iconUrl,
        name,
        url,
        id,
      ];

  factory Source.fromJson(Map<String, dynamic> json) {
    return _$SourceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SourceToJson(this);

  Source copyWith({
    String? iconUrl,
    MangaSourceEnum? name,
    String? url,
    String? id,
  }) {
    return Source(
      iconUrl: iconUrl ?? this.iconUrl,
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
    );
  }

  factory Source.fromFirebaseService(MangaSourceFirebase source) {
    return Source(
      iconUrl: source.iconUrl,
      name: source.name != null ? MangaSourceEnum.fromValue(source.name) : null,
      id: source.id,
      url: source.url,
    );
  }

  MangaSourceFirebase toFirebaseService() {
    return MangaSourceFirebase(
      iconUrl: iconUrl,
      name: name?.value,
      id: id,
      url: url,
    );
  }
}
