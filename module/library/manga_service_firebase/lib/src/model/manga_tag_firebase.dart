import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_tag_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaTagFirebase extends Equatable {
  final String? name;

  final String? id;

  const MangaTagFirebase({
    this.name,
    this.id,
  });

  @override
  List<Object?> get props => [name, id];

  factory MangaTagFirebase.fromFirebase(
    DocumentSnapshot<Map<String, dynamic>> json,
  ) {
    final data = json.data();
    final object = data == null
        ? const MangaTagFirebase()
        : MangaTagFirebase.fromJson(data);
    return object.copyWith(id: json.id);
  }

  factory MangaTagFirebase.fromJson(Map<String, dynamic> json) {
    return _$MangaTagFirebaseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaTagFirebaseToJson(this);

  MangaTagFirebase copyWith({String? name, String? id}) {
    return MangaTagFirebase(name: name ?? this.name, id: id ?? this.id);
  }
}
