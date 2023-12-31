import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class MangaTag extends Equatable with EquatableMixin {
  final String? id;

  final String? name;

  final String? group;

  final bool isIncluded;

  final bool isExcluded;

  const MangaTag({
    this.id,
    this.name,
    this.group,
    this.isIncluded = false,
    this.isExcluded = false,
  });

  @override
  List<Object?> get props => [id, name, group, isIncluded, isExcluded];

  MangaTag copyWith({
    String? id,
    String? name,
    String? group,
    bool? isIncluded,
    bool? isExcluded,
  }) {
    return MangaTag(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      isIncluded: isIncluded ?? this.isIncluded,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }

  factory MangaTag.from(TagData data) {
    return MangaTag(
      id: data.id,
      name: data.attributes?.name?.en,
      group: data.attributes?.group,
    );
  }
}
