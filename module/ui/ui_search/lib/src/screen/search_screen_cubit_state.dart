import 'package:data_manga/manga.dart';
import 'package:equatable/equatable.dart';

class SearchScreenCubitState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Manga> mangas;

  const SearchScreenCubitState({
    this.isLoading = false,
    this.errorMessage,
    this.mangas = const [],
  });

  @override
  List<Object?> get props => [isLoading, errorMessage, mangas];

  SearchScreenCubitState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Manga>? mangas,
  }) {
    return SearchScreenCubitState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      mangas: mangas ?? this.mangas,
    );
  }
}