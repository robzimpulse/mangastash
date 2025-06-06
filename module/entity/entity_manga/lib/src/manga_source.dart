import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import 'enum/manga_source_enum.dart';

part 'manga_source.g.dart';

// TODO: rename to `Source`
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
  List<Object?> get props => [
        iconUrl,
        name,
        url,
        id,
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
  }) {
    return MangaSource(
      iconUrl: iconUrl ?? this.iconUrl,
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
    );
  }

  factory MangaSource.fromFirebaseService(MangaSourceFirebase source) {
    return MangaSource(
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
