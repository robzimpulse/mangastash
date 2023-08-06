// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaResponse _$MangaResponseFromJson(Map<String, dynamic> json) =>
    MangaResponse(
      json['result'] as String?,
      json['response'] as String?,
      json['data'] == null
          ? null
          : MangaData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MangaResponseToJson(MangaResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'response': instance.response,
      'data': instance.data,
    };

MangaData _$MangaDataFromJson(Map<String, dynamic> json) => MangaData(
      json['id'] as String?,
      json['type'] as String?,
      json['attributes'] == null
          ? null
          : MangaDataAttributes.fromJson(
              json['attributes'] as Map<String, dynamic>),
      (json['relationships'] as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Relationship.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MangaDataToJson(MangaData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'attributes': instance.attributes,
      'relationships': instance.relationships,
    };

MangaDataAttributes _$MangaDataAttributesFromJson(Map<String, dynamic> json) =>
    MangaDataAttributes(
      json['title'] == null
          ? null
          : Title.fromJson(json['title'] as Map<String, dynamic>),
      json['description'] == null
          ? null
          : Title.fromJson(json['description'] as Map<String, dynamic>),
      json['isLocked'] as bool?,
      json['originalLanguage'] as String?,
      json['lastVolume'] as String?,
      json['lastChapter'] as String?,
      json['publicationDemographic'] as String?,
      json['status'] as String?,
      json['year'] as num?,
      json['contentRating'] as String?,
      json['state'] as String?,
      json['chapterNumbersResetOnNewVolume'] as bool,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
      json['latestUploadedChapter'] as String?,
      (json['availableTranslatedLanguages'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      (json['tags'] as List<dynamic>)
          .map((e) =>
              e == null ? null : TagData.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['altTitle'] as List<dynamic>?)
          ?.map((e) =>
              e == null ? null : Title.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MangaDataAttributesToJson(
        MangaDataAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'title': instance.title,
      'altTitle': instance.altTitle,
      'description': instance.description,
      'isLocked': instance.isLocked,
      'originalLanguage': instance.originalLanguage,
      'lastVolume': instance.lastVolume,
      'lastChapter': instance.lastChapter,
      'publicationDemographic': instance.publicationDemographic,
      'status': instance.status,
      'year': instance.year,
      'contentRating': instance.contentRating,
      'state': instance.state,
      'chapterNumbersResetOnNewVolume': instance.chapterNumbersResetOnNewVolume,
      'latestUploadedChapter': instance.latestUploadedChapter,
      'availableTranslatedLanguages': instance.availableTranslatedLanguages,
      'tags': instance.tags,
    };
