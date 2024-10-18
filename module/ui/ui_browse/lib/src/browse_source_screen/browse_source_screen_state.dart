import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class BrowseSourceScreenState extends Equatable {
  final List<MangaSource> sources;
  final bool isLoading;
  final Exception? error;

  const BrowseSourceScreenState({
    required this.sources,
    required this.isLoading,
    this.error,
  });

  @override
  List<Object?> get props => [sources, isLoading, error];

  BrowseSourceScreenState copyWith({
    List<MangaSource>? sources,
    bool? isLoading,
    ValueGetter<Exception>? error,
  }) {
    return BrowseSourceScreenState(
      isLoading: isLoading ?? this.isLoading,
      sources: sources ?? this.sources,
      error: error != null ? error() : this.error,
    );
  }
}
