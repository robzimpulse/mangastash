import 'package:equatable/equatable.dart';

class MangaTag extends Equatable {
  final String? id;

  final String? name;

  final bool isIncluded;

  final bool isExcluded;

  const MangaTag({
    this.id,
    this.name,
    this.isIncluded = false,
    this.isExcluded = false,
  });

  @override
  List<Object?> get props => [id, name, isIncluded, isExcluded];

  MangaTag copyWith({
    String? id,
    String? name,
    bool? isIncluded,
    bool? isExcluded,
  }) {
    return MangaTag(
      id: id ?? this.id,
      name: name ?? this.name,
      isIncluded: isIncluded ?? this.isIncluded,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }
}
