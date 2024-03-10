import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseMangaState extends Equatable {
  final bool isLoading;

  final Exception? error;

  final List<MangaDeprecated> mangas;

  final MangaShelfItemLayout layout;

  final String? sourceId;

  final MangaSource? source;

  const BrowseMangaState({
    this.isLoading = false,
    this.error,
    required this.layout,
    this.sourceId,
    this.source,
    this.mangas = const [],
  });

  @override
  List<Object?> get props {
    return [
      error,
      isLoading,
      layout,
      mangas,
      source
    ];
  }

  BrowseMangaState copyWith({
    bool? isLoading,
    ValueGetter<Exception>? error,
    List<MangaDeprecated>? mangas,
    MangaShelfItemLayout? layout,
    String? sourceId,
    MangaSource? source,
  }) {
    return BrowseMangaState(
      isLoading: isLoading ?? this.isLoading,
      mangas: mangas ?? this.mangas,
      error: error != null ? error() : this.error,
      layout: layout ?? this.layout,
      sourceId: sourceId ?? this.sourceId,
      source: source ?? this.source,
    );
  }
}
