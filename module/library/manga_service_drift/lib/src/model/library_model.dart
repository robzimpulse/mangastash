import 'package:equatable/equatable.dart';

import '../../manga_service_drift.dart';

class LibraryModel extends Equatable {
  final MangaDrift? manga;
  final List<TagDrift> tags;

  const LibraryModel({
    this.manga,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [manga, tags];
}