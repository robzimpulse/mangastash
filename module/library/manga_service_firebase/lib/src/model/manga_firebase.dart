import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_firebase.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MangaFirebase extends Equatable {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  final List<String>? tagsId;

  final String? webUrl;

  final String? source;

  const MangaFirebase({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tagsId,
    this.webUrl,
    this.source,
  });

  @override
  List<Object?> get props {
    return [
      id,
      title,
      coverUrl,
      author,
      status,
      description,
      tagsId,
      webUrl,
      source,
    ];
  }

  factory MangaFirebase.fromFirebase(
    DocumentSnapshot<Map<String, dynamic>> json,
  ) {
    final data = json.data();
    final object =
        data == null ? const MangaFirebase() : MangaFirebase.fromJson(data);
    return object.copyWith(id: json.id);
  }

  factory MangaFirebase.fromJson(Map<String, dynamic> json) {
    return _$MangaFirebaseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MangaFirebaseToJson(this);

  MangaFirebase copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
    List<String>? tagsId,
    String? webUrl,
    String? source,
  }) {
    return MangaFirebase(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
      tagsId: tagsId ?? this.tagsId,
      webUrl: webUrl ?? this.webUrl,
      source: source ?? this.source,
    );
  }
}
