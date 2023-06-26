import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class HomeCubitState extends Equatable {
  final bool isLoading;

  final Search? searchData;

  const HomeCubitState({
    this.isLoading = false,
    this.searchData,
  });

  @override
  List<Object?> get props => [isLoading, searchData];

  HomeCubitState copyWith({
    bool? isLoading,
    Search? searchData,
  }) {
    return HomeCubitState(
      isLoading: isLoading ?? this.isLoading,
      searchData: searchData ?? this.searchData
    );
  }
}