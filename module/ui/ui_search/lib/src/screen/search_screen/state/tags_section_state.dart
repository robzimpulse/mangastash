import 'package:data_manga/data_manga.dart';
import 'package:equatable/equatable.dart';

class TagsSectionState extends Equatable {
  final bool isLoading;

  final String? errorMessage;

  final List<Tag> tags;

  const TagsSectionState({
    this.isLoading = false,
    this.errorMessage,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [isLoading, errorMessage, tags];

  TagsSectionState copyWith({
    bool? isLoading,
    String? Function()? errorMessage,
    List<Tag>? tags,
  }) {
    return TagsSectionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      tags: tags ?? this.tags,
    );
  }
}