import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class DetailMangaState extends Equatable with EquatableMixin {
  const DetailMangaState({
    this.manga,
  });

  final Manga? manga;

  @override
  List<Object?> get props => [manga];

  DetailMangaState copyWith({
    Manga? manga,
  }) {
    return DetailMangaState(
      manga: manga ?? this.manga,
    );
  }
}
