import 'package:equatable/equatable.dart';

class Manga extends Equatable {
  final String? id;

  final String? title;

  final String? coverUrl;

  const Manga({this.id, this.title, this.coverUrl});

  @override
  List<Object?> get props => [id, title, coverUrl];

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
