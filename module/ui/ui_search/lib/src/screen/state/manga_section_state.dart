import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

class MangaSectionState extends Equatable {

  final bool isLoading;

  final String? errorMessage;

  final List<Manga> mangas;

  const MangaSectionState({
    this.isLoading = false,
    this.errorMessage,
    this.mangas = const [],
  });

  @override
  List<Object?> get props => [isLoading, errorMessage, mangas];

  MangaSectionState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Manga>? mangas,
  }) {
    return MangaSectionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      mangas: mangas ?? this.mangas,
    );
  }

}