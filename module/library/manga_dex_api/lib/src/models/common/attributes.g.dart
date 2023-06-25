// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attributes _$AttributesFromJson(Map<String, dynamic> json) => Attributes(
      json['title'],
      json['altTitles'] as List<dynamic>?,
      json['description'],
      json['isLocked'] as bool?,
      json['originalLanguage'] as String?,
      json['lastVolume'] as String?,
      json['lastChapter'] as String?,
      json['publicationDemographic'] as String?,
      json['status'] as String?,
      json['year'] as int?,
      json['contentRating'] as String?,
      json['tags'] as List<dynamic>?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as int?,
    );

Map<String, dynamic> _$AttributesToJson(Attributes instance) =>
    <String, dynamic>{
      'title': instance.title,
      'altTitles': instance.altTitles,
      'description': instance.description,
      'isLocked': instance.isLocked,
      'originalLanguage': instance.originalLanguage,
      'lastVolume': instance.lastVolume,
      'lastChapter': instance.lastChapter,
      'publicationDemographic': instance.publicationDemographic,
      'status': instance.status,
      'year': instance.year,
      'contentRating': instance.contentRating,
      'tags': instance.tags,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
    };
