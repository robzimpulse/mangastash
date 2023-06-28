import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class Manga extends Equatable {
  final String? id;

  final String? title;

  final String? coverUrl;

  const Manga({required this.id, this.title, this.coverUrl});

  @override
  List<Object?> get props => [id, title, coverUrl];

  factory Manga.fromData({required SearchData data}) {
    return Manga(
      id: data.id,
      title: data.attributes?.title?.en,
      coverUrl: null,
    );
  }

  Manga copyWith({
    String? id,
    String? title,
    String? coverUrl,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
