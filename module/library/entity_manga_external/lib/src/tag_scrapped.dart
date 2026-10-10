import 'package:equatable/equatable.dart';

import 'json_fields.dart';

/// A genre/tag as scraped from an external source.
///
/// Created by Dart source parsers directly, or by `TagScrapped.fromJson(map)`
/// from the JSON returned by a scripted source. Unknown JSON keys are ignored;
/// a field with the wrong type throws a [FormatException] naming the field.
class TagScrapped extends Equatable {
  final String? id;
  final String? name;

  const TagScrapped({this.id, this.name});

  factory TagScrapped.fromJson(Map<String, dynamic> json) {
    return TagScrapped(
      id: optionalString(json, 'id'),
      name: optionalString(json, 'name'),
    );
  }

  @override
  List<Object?> get props => [id, name];
}
