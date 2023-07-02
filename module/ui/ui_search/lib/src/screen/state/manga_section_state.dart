import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

class MangaSectionState extends Equatable {
  final bool isLoading;

  final String? errorMessage;

  final List<Manga> mangas;

  final bool hasNextPage;

  final bool isPaging;

  const MangaSectionState({
    this.isPaging = false,
    this.hasNextPage = false,
    this.isLoading = false,
    this.errorMessage,
    this.mangas = const [],
  });

  @override
  List<Object?> get props {
    return [
      isLoading,
      errorMessage,
      mangas,
      isPaging,
      hasNextPage,
    ];
  }

  MangaSectionState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Manga>? mangas,
    bool? isPaging,
    bool? hasNextPage,
  }) {
    return MangaSectionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      mangas: mangas ?? this.mangas,
      isPaging: isPaging ?? this.isPaging,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
