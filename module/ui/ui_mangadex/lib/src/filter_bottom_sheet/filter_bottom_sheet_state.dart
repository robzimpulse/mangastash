import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class FilterBottomSheetState extends Equatable with EquatableMixin {
  const FilterBottomSheetState({
    this.tags = const [],
    this.includedTags = const [],
    this.excludedTags = const [],
    this.originalIncludedTags = const [],
    this.originalExcludedTags = const [],
  });

  final List<MangaTagDeprecated> tags;

  final List<String> includedTags;

  final List<String> excludedTags;

  final List<String> originalIncludedTags;

  final List<String> originalExcludedTags;

  @override
  List<Object?> get props {
    return [
      tags,
      includedTags,
      excludedTags,
      originalIncludedTags,
      originalExcludedTags,
    ];
  }

  List<MapEntry<String?, List<MangaTagDeprecated>>> get groups {
    return finalTag.groupListsBy((e) => e.group).entries.toList();
  }

  List<MangaTagDeprecated> get finalTag {
    return tags
        .map(
          (e) => e.copyWith(
            isExcluded: excludedTags.contains(e.id),
            isIncluded: includedTags.contains(e.id),
          ),
        )
        .toList();
  }

  FilterBottomSheetState copyWith({
    List<MangaTagDeprecated>? tags,
    List<String>? includedTags,
    List<String>? excludedTags,
    List<String>? originalIncludedTags,
    List<String>? originalExcludedTags,
  }) {
    return FilterBottomSheetState(
      tags: tags ?? this.tags,
      originalExcludedTags: originalExcludedTags ?? this.originalExcludedTags,
      originalIncludedTags: originalIncludedTags ?? this.originalIncludedTags,
      includedTags: includedTags ?? this.includedTags,
      excludedTags: excludedTags ?? this.excludedTags,
    );
  }
}
