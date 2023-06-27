import 'package:equatable/equatable.dart';

class HomeCubitState extends Equatable {
  final bool isLoading;

  const HomeCubitState({
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [isLoading];

  HomeCubitState copyWith({
    bool? isLoading,
  }) {
    return HomeCubitState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}