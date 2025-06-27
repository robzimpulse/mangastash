import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'source.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Source extends Equatable {
  final String? icon;

  final String? name;

  final String? url;

  const Source({
    this.icon,
    this.name,
    this.url,
  });

  @override
  List<Object?> get props => [icon, name, url];

  factory Source.fromJson(Map<String, dynamic> json) {
    return _$SourceFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SourceToJson(this);

  String toJsonString() => json.encode(toJson());

  static Source? fromJsonString(String json) {
    try {
      return Source.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  Source copyWith({
    String? icon,
    String? name,
    String? url,
  }) {
    return Source(
      icon: icon ?? this.icon,
      name: name ?? this.name,
      url: url ?? this.url,
    );
  }

  static List<Source> values = [
    Source.mangadex(),
    Source.mangaclash(),
    Source.asurascan(),
  ];

  static Source? fromValue(String? value) {
    return values.firstWhereOrNull(
      (e) => e.name == value,
    );
  }

  factory Source.mangadex() {
    return const Source(
      name: 'Manga Dex',
      icon: 'https://www.mangadex.org/favicon.ico',
      url: 'https://www.mangadex.org',
    );
  }

  factory Source.mangaclash() {
    return const Source(
      icon: 'https://toonclash.com/wp-content/uploads/2020/03/cropped-22.jpg',
      name: 'Manga Clash',
      url: 'https://toonclash.com',
    );
  }

  factory Source.asurascan() {
    return const Source(
      name: 'Asura Scans',
      url: 'https://asuracomic.net',
      icon: 'https://asuracomic.net/images/logo.webp',
    );
  }
}
