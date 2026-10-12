import 'package:equatable/equatable.dart';

import 'json_fields.dart';

/// A manga as scraped from an external source.
///
/// Created by Dart source parsers directly, or by `MangaScrapped.fromJson(map)`
/// from the JSON returned by a scripted source. Unknown JSON keys are ignored;
/// a field with the wrong type throws a [FormatException] naming the field.
class MangaScrapped extends Equatable {
  final String? id;
  final String? title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final String? description;
  final List<String>? tags;
  final String? webUrl;
  final String? createdAt;
  final String? updatedAt;

  const MangaScrapped({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
    this.tags,
    this.webUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MangaScrapped.fromJson(Map<String, dynamic> json) {
    return MangaScrapped(
      id: optionalString(json, 'id'),
      title: optionalString(json, 'title'),
      coverUrl: optionalString(json, 'coverUrl'),
      author: optionalString(json, 'author'),
      status: optionalString(json, 'status'),
      description: optionalString(json, 'description'),
      tags: optionalStringList(json, 'tags'),
      webUrl: optionalString(json, 'webUrl'),
      createdAt: optionalString(json, 'createdAt'),
      updatedAt: optionalString(json, 'updatedAt'),
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      title,
      coverUrl,
      author,
      status,
      description,
      tags,
      webUrl,
      createdAt,
      updatedAt,
    ];
  }
}
