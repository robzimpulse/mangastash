import 'package:equatable/equatable.dart';

import 'manga.dart';

class PaginationManga extends Equatable with EquatableMixin {

  final int? offset;

  final int? limit;

  final List<Manga>? mangas;

  const PaginationManga({this.offset, this.limit, this.mangas});

  @override
  List<Object?> get props => [mangas, offset, limit];

  PaginationManga copyWith({
    int? offset,
    int? limit,
    List<Manga>? mangas,
  }) {
    return PaginationManga(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      mangas: mangas ?? this.mangas,
    );
  }
}