import 'package:equatable/equatable.dart';

class PickerBottomSheetState extends Equatable {
  PickerBottomSheetState({
    this.options,
    this.keyword,
    this.selected,
  }) {
    final keyword = this.keyword;
    filtered = keyword == null || keyword.isEmpty
        ? List.from(options ?? [])
        : List.from(
            (options ?? []).where(
              (e) => e.toLowerCase().contains(keyword.toLowerCase()),
            ),
          );
  }

  final String? keyword;

  final List<String>? options;

  final String? selected;

  late final List<String> filtered;

  @override
  List<Object?> get props => [options, keyword, selected, filtered];

  PickerBottomSheetState copyWith({
    List<String>? options,
    String? keyword,
    String? selected,
  }) {
    return PickerBottomSheetState(
      options: options ?? this.options,
      keyword: keyword ?? this.keyword,
      selected: selected ?? this.selected,
    );
  }
}
