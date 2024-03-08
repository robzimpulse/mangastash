import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manga_source.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MangaSource extends Equatable {

  final String iconUrl;

  final String name;

  final String url;

  final String id;

  const MangaSource({
    this.iconUrl = '',
    required this.name,
    required this.url,
    required this.id,
  });

  @override
  List<Object?> get props => [iconUrl, name, url, id];

  factory MangaSource.fromJson(Map<String, dynamic> json) {
    return _$MangaSourceFromJson(json);
  }
  Map<String, dynamic> toJson() => _$MangaSourceToJson(this);
}