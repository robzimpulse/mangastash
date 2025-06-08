import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseScreenState extends Equatable {
  final SearchMangaParameter parameter;

  const BrowseScreenState({
    this.parameter = const SearchMangaParameter(),
  });

  @override
  List<Object?> get props => [parameter];

  BrowseScreenState copyWith({
    SearchMangaParameter? parameter,
  }) {
    return BrowseScreenState(
      parameter: parameter ?? this.parameter,
    );
  }
}
