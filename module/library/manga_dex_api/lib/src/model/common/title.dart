import 'package:json_annotation/json_annotation.dart';

part 'title.g.dart';

///@nodoc
@JsonSerializable()
class Title {
  final String? en;
  final String? fr;
  final String? it;
  final String? zh;
  @JsonKey(name: 'ja-ro')
  final String? jaRo;

  const Title(this.en, this.fr, this.it, this.zh, this.jaRo);

  factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);

  Map<String, dynamic> toJson() => _$TitleToJson(this);
}
