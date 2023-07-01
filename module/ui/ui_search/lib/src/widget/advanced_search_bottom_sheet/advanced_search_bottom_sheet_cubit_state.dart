import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

class AdvancedSearchBottomSheetCubitState extends Equatable {
  final List<Tag> tags;

  final List<Tag> originalTags;

  final TagsMode mode;

  final TagsMode originalMode;

  const AdvancedSearchBottomSheetCubitState({
    required this.tags,
    required this.originalTags,
    required this.mode,
    required this.originalMode,
  });

  @override
  List<Object?> get props => [tags, originalTags, mode, originalMode];

  AdvancedSearchBottomSheetCubitState copyWith({
    List<Tag>? tags,
    TagsMode? mode,
  }) {
    return AdvancedSearchBottomSheetCubitState(
      tags: tags ?? this.tags,
      originalTags: originalTags,
      mode: mode ?? this.mode,
      originalMode: originalMode,
    );
  }

  List<Tag> get sortedTag {
    return List.from(tags)
      ..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
  }

  List<Tag> get sortedOriginal {
    return List.from(originalTags)
      ..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
  }

  List<String> get includedTagsId {
    return tags
        .where((e) => e.isIncluded)
        .map((e) => e.id)
        .whereType<String>()
        .toList();
  }

  List<String> get excludedTagsId {
    return tags
        .where((e) => e.isExcluded)
        .map((e) => e.id)
        .whereType<String>()
        .toList();
  }

  bool get isTagModeAnd => mode == TagsMode.and;
}
