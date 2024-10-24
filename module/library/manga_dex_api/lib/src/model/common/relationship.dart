import 'package:json_annotation/json_annotation.dart';

import '../../enums/includes.dart';
import '../author/author_data_attributes.dart';
import '../cover_art/cover_art_data_attributes.dart';
import '../manga/manga_data_attributes.dart';
import '../scanlation_group/scanlation_group_data_attributes.dart';
import '../tag/tag_response.dart';
import 'attribute.dart';
import 'identifier.dart';

part 'relationship.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Relationship<T extends Attribute> extends Identifier {
  final String? related;
  final T? attributes;

  Relationship(super.id, super.type, this.related, this.attributes);

  factory Relationship.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return _$RelationshipFromJson(json, fromJsonT);
  }

  Map<String, dynamic> toJson(
    Object? Function(T value) toJsonT,
  ) =>
      _$RelationshipToJson(this, toJsonT);

  static List<Relationship> from(List<dynamic> json) {
    List<Relationship> relationships = [];
    for (final value in json) {
      final data = value as Map<String, dynamic>?;
      if (data == null) continue;
      final type = data['type'] as String?;
      if (type == null) continue;

      switch (Include.fromRawValue(type)) {
        case Include.coverArt:
          relationships.add(
            Relationship<CoverArtDataAttributes>.fromJson(
              data,
              (json) => CoverArtDataAttributes.fromJson(
                json as Map<String, dynamic>,
              ),
            ),
          );
        case Include.author:
          relationships.add(
            Relationship<AuthorDataAttributes>.fromJson(
              data,
              (json) => AuthorDataAttributes.fromJson(
                json as Map<String, dynamic>,
              ),
            ),
          );
        case Include.artist:
          // TODO: add this relationship when artist data attribute exists
          break;
        case Include.tag:
          relationships.add(
            Relationship<TagDataAttributes>.fromJson(
              data,
              (json) => TagDataAttributes.fromJson(
                json as Map<String, dynamic>,
              ),
            ),
          );
        case Include.creator:
          // TODO: add this relationship when creator data attribute exists
          break;
        case Include.scanlationGroup:
          relationships.add(
            Relationship<ScanlationGroupDataAttributes>.fromJson(
              data,
              (json) => ScanlationGroupDataAttributes.fromJson(
                json as Map<String, dynamic>,
              ),
            ),
          );
        case Include.manga:
          relationships.add(
            Relationship<MangaDataAttributes>.fromJson(
              data,
              (json) => MangaDataAttributes.fromJson(
                json as Map<String, dynamic>,
              ),
            ),
          );
        case Include.user:
        // TODO: add this relationship when user data attribute exists
          break;
      }
    }

    return relationships;
  }
}
