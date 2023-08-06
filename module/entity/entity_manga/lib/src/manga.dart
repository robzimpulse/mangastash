import 'package:equatable/equatable.dart';

class Manga extends Equatable with EquatableMixin {
  final String? id;

  final String? title;

  final String? coverUrl;

  final String? author;

  final String? status;

  final String? description;

  const Manga({
    this.id,
    this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, coverUrl, author, status, description];

  Manga copyWith({
    String? id,
    String? title,
    String? coverUrl,
    String? author,
    String? status,
    String? description,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      author: author ?? this.author,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}
