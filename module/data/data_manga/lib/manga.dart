import 'package:equatable/equatable.dart';

class Manga extends Equatable {

  final String? id;

  final String? title;

  final String? coverUrl;

  const Manga({required this.id, this.title, this.coverUrl});

  @override
  List<Object?> get props => [id, title, coverUrl];

}