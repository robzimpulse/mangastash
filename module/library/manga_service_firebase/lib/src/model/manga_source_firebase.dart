import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_source_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaSourceFirebase extends Equatable {
  final String? iconUrl;

  final String? name;

  final String? url;

  final String? id;

  const MangaSourceFirebase({
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

  factory MangaSourceFirebase.fromJson(Map<String, dynamic> json) {
    return _$MangaSourceFirebaseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaSourceFirebaseToJson(this);

  MangaSourceFirebase copyWith({
    String? iconUrl,
    String? name,
    String? url,
    String? id,
  }) {
    return MangaSourceFirebase(
      iconUrl: iconUrl ?? this.iconUrl,
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
    );
  }
}
