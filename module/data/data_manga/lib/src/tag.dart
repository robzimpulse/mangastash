import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String? id;

  final String? name;

  final bool isIncluded;

  final bool isExcluded;

  const Tag({
    this.id,
    this.name,
    this.isIncluded = false,
    this.isExcluded = false,
  });

  @override
  List<Object?> get props => [id, name, isIncluded, isExcluded];

  Tag copyWith({
    String? id,
    String? name,
    bool? isIncluded,
    bool? isExcluded,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      isIncluded: isIncluded ?? this.isIncluded,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }
}
