import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:text_similarity/text_similarity.dart';

import 'base_model.dart';

part 'manga_tag_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaTagFirebase extends BaseModel {
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

  @override
  double similarity(other) {
    if (other is! MangaTagFirebase) return 0;

    final matcher = StringMatcher(
      term: TermEnum.char,
      algorithm: const LevenshteinAlgorithm(),
    );

    return matcher.similar(name, other.name)?.ratio ?? 0;
  }

  @override
  MangaTagFirebase merge(other) {
    if (other is! MangaTagFirebase) return this;

    return copyWith(
      id: id ?? other.id,
      name: name ?? other.name,
    );
  }
}
