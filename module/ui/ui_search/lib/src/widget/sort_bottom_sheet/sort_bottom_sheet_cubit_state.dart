import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

class SortBottomSheetCubitState extends Equatable {
  final List<Tag> tags;

  final List<Tag> original;

  const SortBottomSheetCubitState({required this.tags, required this.original});

  @override
  List<Object?> get props => [tags];

  SortBottomSheetCubitState copyWith({List<Tag>? tags}) {
    return SortBottomSheetCubitState(
      tags: tags ?? this.tags,
      original: original,
    );
  }

  List<Tag> get sortedTag =>
      List.from(tags)..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);

  List<Tag> get sortedOriginal =>
      List.from(original)..sort((a, b) => a.name?.compareTo(b.name ?? '') ?? 0);
}
