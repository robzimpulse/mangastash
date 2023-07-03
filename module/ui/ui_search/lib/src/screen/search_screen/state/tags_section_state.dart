import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class TagsSectionState extends Equatable {
  final bool isLoading;

  final List<Tag> tags;

  const TagsSectionState({
    this.isLoading = true,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [isLoading, tags];

  TagsSectionState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Tag>? tags,
  }) {
    return TagsSectionState(
      isLoading: isLoading ?? this.isLoading,
      tags: tags ?? this.tags,
    );
  }
}