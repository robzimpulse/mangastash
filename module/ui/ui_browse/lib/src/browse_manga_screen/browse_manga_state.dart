import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class BrowseMangaState extends Equatable with EquatableMixin {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  const BrowseMangaState({
    this.isLoading = false,
    this.error,
    this.mangas = const [],
  });

  @override
  List<Object?> get props {
    return [
      error,
      isLoading,
      mangas,
    ];
  }

  BrowseMangaState copyWith({
    bool? isLoading,
    ValueGetter<Exception>? error,
    List<Manga>? mangas,
  }) {
    return BrowseMangaState(
      isLoading: isLoading ?? this.isLoading,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
    );
  }
}