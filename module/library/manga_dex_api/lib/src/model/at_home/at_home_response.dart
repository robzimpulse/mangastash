import 'package:json_annotation/json_annotation.dart';

import 'at_home_chapter.dart';

part 'at_home_response.g.dart';

@JsonSerializable()
class AtHomeResponse {
  final String? result;
  final String? baseUrl;
  final AtHomeChapter? chapter;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<String>? images;
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final List<String>? imagesDataSaver;

  AtHomeResponse(this.result, this.baseUrl, this.chapter) {
    final hash = chapter?.hash;
    final data = chapter?.data ?? [];
    final saver = chapter?.dataSaver ?? [];

    imagesDataSaver = hash != null
        ? [for (final chapter in saver) '$baseUrl/data-saver/$hash/$chapter']
        : [];

    images = hash != null
        ? [for (final chapter in data) '$baseUrl/data/$hash/$chapter']
        : [];
  }

  factory AtHomeResponse.fromJson(Map<String, dynamic> json) {
    return _$AtHomeResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AtHomeResponseToJson(this);
}

Map<String, dynamic> serializeAtHomeResponse(AtHomeResponse object) =>
    object.toJson();

AtHomeResponse deserializeAtHomeResponse(Map<String, dynamic> json) =>
    AtHomeResponse.fromJson(json);
