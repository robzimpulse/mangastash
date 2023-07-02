import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

class SearchParameterEditorScreenCubitState extends Equatable {
  final SearchMangaParameter parameter;

  final List<Tag> tags;

  const SearchParameterEditorScreenCubitState({
    required this.parameter,
    required this.tags,
  });

  @override
  List<Object?> get props => [parameter, tags];

  SearchParameterEditorScreenCubitState copyWith({
    SearchMangaParameter? parameter,
    List<Tag>? tags,
  }) {
    return SearchParameterEditorScreenCubitState(
      parameter: parameter ?? this.parameter,
      tags: tags ?? this.tags,
    );
  }
}
