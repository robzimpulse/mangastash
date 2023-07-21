import 'package:equatable/equatable.dart';

class MangaTag extends Equatable {
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
}
