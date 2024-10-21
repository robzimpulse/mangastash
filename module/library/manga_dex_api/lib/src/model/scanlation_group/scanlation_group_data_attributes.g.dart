// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanlation_group_data_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanlationGroupDataAttributes _$ScanlationGroupDataAttributesFromJson(
        Map<String, dynamic> json) =>
    ScanlationGroupDataAttributes(
      json['name'] as String?,
      (json['altNames'] as List<dynamic>?)
          ?.map((e) => Title.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['locked'] as bool?,
      json['website'] as String?,
      json['ircServer'] as String?,
      json['ircChannel'] as String?,
      json['discord'] as String?,
      json['contactEmail'] as String?,
      json['description'] as String?,
      json['twitter'] as String?,
      json['mangaUpdates'] as String?,
      (json['focusedLanguages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      json['official'] as bool?,
      json['verified'] as bool?,
      json['inactive'] as bool?,
      json['publishDelay'] as String?,
      json['exLicensed'] as bool?,
      json['createdAt'] as String?,
      json['updatedAt'] as String?,
      json['version'] as num?,
    );

Map<String, dynamic> _$ScanlationGroupDataAttributesToJson(
        ScanlationGroupDataAttributes instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'name': instance.name,
      'altNames': instance.altNames,
      'locked': instance.locked,
      'website': instance.website,
      'ircServer': instance.ircServer,
      'ircChannel': instance.ircChannel,
      'discord': instance.discord,
      'contactEmail': instance.contactEmail,
      'description': instance.description,
      'twitter': instance.twitter,
      'mangaUpdates': instance.mangaUpdates,
      'focusedLanguages': instance.focusedLanguages,
      'official': instance.official,
      'verified': instance.verified,
      'inactive': instance.inactive,
      'publishDelay': instance.publishDelay,
      'exLicensed': instance.exLicensed,
    };
