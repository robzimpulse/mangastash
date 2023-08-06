import 'package:equatable/equatable.dart';

class MangaChapter extends Equatable with EquatableMixin {
  final String? id;

  final String? name;

  const MangaChapter({
    this.id,
    this.name,
  });

  @override
  List<Object?> get props => [id, name];

  MangaChapter copyWith({
    String? id,
    String? name,
  }) {
    return MangaChapter(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
