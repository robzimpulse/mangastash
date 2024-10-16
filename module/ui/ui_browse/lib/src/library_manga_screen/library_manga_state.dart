import 'package:core_auth/core_auth.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class LibraryMangaState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final AuthState? authState;

  const LibraryMangaState({
    this.isLoading = false,
    this.error,
    this.mangas = const [],
    this.authState,
  });

  @override
  List<Object?> get props {
    return [
      isLoading,
      error,
      mangas,
      authState,
    ];
  }

  LibraryMangaState copyWith({
    bool? isLoading,
    ValueGetter<Exception?>? error,
    List<Manga>? mangas,
    AuthState? authState,
  }) {
    return LibraryMangaState(
      isLoading: isLoading ?? this.isLoading,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
      authState: authState ?? this.authState,
    );
  }
}
