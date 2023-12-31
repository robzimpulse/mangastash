import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class DetailMangaState extends Equatable with EquatableMixin {
  const DetailMangaState({
    this.isLoading = false,
    this.errorMessage,
    this.manga,
    this.parameter = const SearchChapterParameter(),
  });

  final Manga? manga;

  final SearchChapterParameter parameter;

  final bool isLoading;

  final String? errorMessage;

  @override
  List<Object?> get props => [manga, isLoading, errorMessage, parameter];

  DetailMangaState copyWith({
    Manga? manga,
    SearchChapterParameter? parameter,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return DetailMangaState(
      manga: manga ?? this.manga,
      parameter: parameter ?? this.parameter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
