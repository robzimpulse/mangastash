import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class ReaderMangaState extends Equatable with EquatableMixin {
  const ReaderMangaState({
    this.isLoading = false,
    this.chapter,
    this.errorMessage,
  });

  final bool isLoading;

  final String? errorMessage;

  final MangaChapter? chapter;

  @override
  List<Object?> get props => [isLoading, chapter, errorMessage];

  ReaderMangaState copyWith({
    bool? isLoading,
    MangaChapter? chapter,
    String? Function()? errorMessage,
  }) {
    return ReaderMangaState(
      isLoading: isLoading ?? this.isLoading,
      chapter: chapter ?? this.chapter,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
