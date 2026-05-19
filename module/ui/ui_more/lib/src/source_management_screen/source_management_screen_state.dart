import 'package:equatable/equatable.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

class SourceManagementScreenState extends Equatable {
  final List<DynamicSourceDrift> dynamicSources;
  final bool isLoading;
  final String? error;

  const SourceManagementScreenState({
    this.dynamicSources = const [],
    this.isLoading = false,
    this.error,
  });

  SourceManagementScreenState copyWith({
    List<DynamicSourceDrift>? dynamicSources,
    bool? isLoading,
    String? error,
  }) {
    return SourceManagementScreenState(
      dynamicSources: dynamicSources ?? this.dynamicSources,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [dynamicSources, isLoading, error];
}
