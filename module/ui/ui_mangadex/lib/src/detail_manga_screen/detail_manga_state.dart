import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class DetailMangaState extends Equatable with EquatableMixin {
  const DetailMangaState({
    this.isLoading = false,
    this.errorMessage,
    this.manga,
  });

  final Manga? manga;

  final bool isLoading;

  final String? errorMessage;

  @override
  List<Object?> get props => [manga, isLoading, errorMessage];

  DetailMangaState copyWith({
    Manga? manga,
    MangaData? data,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return DetailMangaState(
      manga: manga ?? this.manga,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
