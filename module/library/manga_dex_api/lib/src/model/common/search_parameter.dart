import 'package:equatable/equatable.dart';

import '../../enums/content_rating.dart';
import '../../enums/includes.dart';
import '../../enums/language_codes.dart';

class SearchParameter extends Equatable {
  final int limit;
  final int offset;
  final int page;

  final String? updatedAtSince;
  final List<Include>? includes;
  final List<ContentRating>? contentRating;
  final List<LanguageCodes>? originalLanguage;
  final List<LanguageCodes>? excludedOriginalLanguages;
  final String? createdAtSince;
  final List<String>? ids;

  const SearchParameter({
    this.limit = 20,
    this.offset = 0,
    this.page = 1,
    this.updatedAtSince,
    this.includes,
    this.contentRating,
    this.originalLanguage,
    this.excludedOriginalLanguages,
    this.createdAtSince,
    this.ids,
  });

  @override
  List<Object?> get props {
    return [
      limit,
      offset,
      page,
      updatedAtSince,
      includes,
      contentRating,
      originalLanguage,
      excludedOriginalLanguages,
      createdAtSince,
      ids,
    ];
  }

  SearchParameter copyWith({
    int? limit,
    int? offset,
    int? page,
    String? updatedAtSince,
    List<Include>? includes,
    List<ContentRating>? contentRating,
    List<LanguageCodes>? originalLanguage,
    List<LanguageCodes>? excludedOriginalLanguages,
    String? createdAtSince,
    List<String>? ids,
  }) {
    return SearchParameter(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      page: page ?? this.page,
      updatedAtSince: updatedAtSince ?? this.updatedAtSince,
      includes: includes ?? this.includes,
      contentRating: contentRating ?? this.contentRating,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      excludedOriginalLanguages:
          excludedOriginalLanguages ?? this.excludedOriginalLanguages,
      createdAtSince: createdAtSince ?? this.createdAtSince,
      ids: ids ?? this.ids,
    );
  }
}
