import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaState extends Equatable with EquatableMixin {
  final bool isLoading;

  final Exception? error;

  final List<Manga> mangas;

  final MangaShelfItemLayout layout;

  const BrowseMangaState({
    this.isLoading = false,
    this.error,
    required this.layout,
    this.mangas = const [],
  });

  @override
  List<Object?> get props {
    return [
      error,
      isLoading,
      layout,
      mangas,
    ];
  }

  BrowseMangaState copyWith({
    bool? isLoading,
    ValueGetter<Exception>? error,
    List<Manga>? mangas,
    MangaShelfItemLayout? layout,
  }) {
    return BrowseMangaState(
      isLoading: isLoading ?? this.isLoading,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
      layout: layout ?? this.layout
    );
  }
}