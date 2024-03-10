import 'package:equatable/equatable.dart';

import 'manga.dart';

class PaginationMangaDeprecated extends Equatable with EquatableMixin {
  final int? offset;
  final int? total;
  final int? limit;

  final List<MangaDeprecated>? mangas;

  const PaginationMangaDeprecated({this.offset, this.limit, this.total, this.mangas});

  @override
  List<Object?> get props => [mangas, offset, limit, total];

  PaginationMangaDeprecated copyWith({
    int? offset,
    int? limit,
    int? total,
    List<MangaDeprecated>? mangas,
  }) {
    return PaginationMangaDeprecated(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      mangas: mangas ?? this.mangas,
    );
  }
}
