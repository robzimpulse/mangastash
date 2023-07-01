import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

class AdvancedSearchBottomSheetCubitState extends Equatable {
  final List<Tag> tags;

  final SearchMangaParameter parameter;

  final SearchMangaParameter original;

  const AdvancedSearchBottomSheetCubitState({
    required this.tags,
    required this.original,
    required this.parameter,
  });

  @override
  List<Object?> get props => [tags, original, parameter];

  AdvancedSearchBottomSheetCubitState copyWith({
    List<Tag>? tags,
    SearchMangaParameter? parameter,
  }) {
    return AdvancedSearchBottomSheetCubitState(
      parameter: parameter ?? this.parameter,
      tags: tags ?? this.tags,
      original: original,
    );
  }

  List<Tag> get sortedTag {
    final updated = tags.map(
      (e) => e.copyWith(
        isIncluded: parameter.includedTags?.contains(e.id),
        isExcluded: parameter.excludedTags?.contains(e.id),
      ),
    );
    return List.from(updated)
      ..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
  }
}
