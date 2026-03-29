import 'package:equatable/equatable.dart';

class TagScrapped extends Equatable {
  final String? id;
  final String? name;

  const TagScrapped({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}
