// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_source.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MangaSourceCWProxy {
  MangaSource iconUrl(String? iconUrl);

  MangaSource name(String? name);

  MangaSource url(String? url);

  MangaSource id(String? id);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MangaSource(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MangaSource(...).copyWith(id: 12, name: "My name")
  /// ````
  MangaSource call({
    String? iconUrl,
    String? name,
    String? url,
    String? id,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMangaSource.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMangaSource.copyWith.fieldName(...)`
class _$MangaSourceCWProxyImpl implements _$MangaSourceCWProxy {
  const _$MangaSourceCWProxyImpl(this._value);

  final MangaSource _value;

  @override
  MangaSource iconUrl(String? iconUrl) => this(iconUrl: iconUrl);

  @override
  MangaSource name(String? name) => this(name: name);

  @override
  MangaSource url(String? url) => this(url: url);

  @override
  MangaSource id(String? id) => this(id: id);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MangaSource(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MangaSource(...).copyWith(id: 12, name: "My name")
  /// ````
  MangaSource call({
    Object? iconUrl = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
  }) {
    return MangaSource(
      iconUrl: iconUrl == const $CopyWithPlaceholder()
          ? _value.iconUrl
          // ignore: cast_nullable_to_non_nullable
          : iconUrl as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
    );
  }
}

extension $MangaSourceCopyWith on MangaSource {
  /// Returns a callable class that can be used as follows: `instanceOfMangaSource.copyWith(...)` or like so:`instanceOfMangaSource.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MangaSourceCWProxy get copyWith => _$MangaSourceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaSource _$MangaSourceFromJson(Map<String, dynamic> json) => MangaSource(
      iconUrl: json['icon_url'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$MangaSourceToJson(MangaSource instance) =>
    <String, dynamic>{
      'icon_url': instance.iconUrl,
      'name': instance.name,
      'url': instance.url,
      'id': instance.id,
    };
