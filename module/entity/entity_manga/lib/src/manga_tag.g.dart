// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_tag.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MangaTagCWProxy {
  MangaTag name(String? name);

  MangaTag id(String? id);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MangaTag(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MangaTag(...).copyWith(id: 12, name: "My name")
  /// ````
  MangaTag call({
    String? name,
    String? id,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMangaTag.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMangaTag.copyWith.fieldName(...)`
class _$MangaTagCWProxyImpl implements _$MangaTagCWProxy {
  const _$MangaTagCWProxyImpl(this._value);

  final MangaTag _value;

  @override
  MangaTag name(String? name) => this(name: name);

  @override
  MangaTag id(String? id) => this(id: id);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MangaTag(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MangaTag(...).copyWith(id: 12, name: "My name")
  /// ````
  MangaTag call({
    Object? name = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
  }) {
    return MangaTag(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
    );
  }
}

extension $MangaTagCopyWith on MangaTag {
  /// Returns a callable class that can be used as follows: `instanceOfMangaTag.copyWith(...)` or like so:`instanceOfMangaTag.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MangaTagCWProxy get copyWith => _$MangaTagCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaTag _$MangaTagFromJson(Map<String, dynamic> json) => MangaTag(
      name: json['name'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$MangaTagToJson(MangaTag instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };
