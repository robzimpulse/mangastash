import 'package:data_manga/manga.dart';
import 'package:equatable/equatable.dart';

class HomeCubitState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Manga> mangas;

  const HomeCubitState({
    this.isLoading = false,
    this.errorMessage,
    this.mangas = const [],
  });

  @override
  List<Object?> get props => [isLoading, errorMessage, mangas];

  HomeCubitState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Manga>? mangas,
  }) {
    return HomeCubitState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      mangas: mangas ?? this.mangas,
    );
  }
}