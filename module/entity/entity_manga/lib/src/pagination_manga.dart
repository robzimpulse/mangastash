import 'package:equatable/equatable.dart';

import 'manga.dart';

class PaginationManga extends Equatable with EquatableMixin {
  final int? offset;
  final int? total;
  final int? limit;

  final List<Manga>? mangas;

  const PaginationManga({this.offset, this.limit, this.total, this.mangas});

  @override
  List<Object?> get props => [mangas, offset, limit, total];

  PaginationManga copyWith({
    int? offset,
    int? limit,
    int? total,
    List<Manga>? mangas,
  }) {
    return PaginationManga(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      mangas: mangas ?? this.mangas,
    );
  }
}
