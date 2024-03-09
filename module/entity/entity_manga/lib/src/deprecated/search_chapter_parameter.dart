import 'package:equatable/equatable.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchChapterParameterDeprecated extends Equatable with EquatableMixin {
  final int? limit;
  final int? offset;
  final String? mangaId;
  final String? title;
  final String? uploader;
  final String? volume;
  final String? chapter;
  final String? createdAtSince;
  final String? updatedAtSince;
  final String? publishedAtSince;
  final List<String>? ids;
  final List<String>? groups;
  final List<LanguageCodes>? translatedLanguage;
  final List<LanguageCodes>? originalLanguage;
  final List<LanguageCodes>? excludedOriginalLanguage;
  final List<ContentRating>? contentRating;
  final List<Include>? includes;
  final Map<ChapterOrders, OrderDirections>? orders;

  const SearchChapterParameterDeprecated({
    this.limit,
    this.offset,
    this.mangaId,
    this.title,
    this.uploader,
    this.volume,
    this.chapter,
    this.createdAtSince,
    this.updatedAtSince,
    this.publishedAtSince,
    this.ids,
    this.groups,
    this.translatedLanguage,
    this.originalLanguage,
    this.excludedOriginalLanguage,
    this.contentRating,
    this.includes,
    this.orders,
  });

  @override
  List<Object?> get props {
    return [
      limit,
      offset,
      mangaId,
      title,
      uploader,
      volume,
      chapter,
      createdAtSince,
      updatedAtSince,
      publishedAtSince,
      ids,
      groups,
      translatedLanguage,
      originalLanguage,
      excludedOriginalLanguage,
      contentRating,
      includes,
      orders,
    ];
  }

  SearchChapterParameterDeprecated copyWith({
    int? limit,
    int? offset,
    String? mangaId,
    String? title,
    String? uploader,
    String? volume,
    String? chapter,
    String? createdAtSince,
    String? updatedAtSince,
    String? publishedAtSince,
    List<String>? ids,
    List<String>? groups,
    List<LanguageCodes>? translatedLanguage,
    List<LanguageCodes>? originalLanguage,
    List<LanguageCodes>? excludedOriginalLanguage,
    List<ContentRating>? contentRating,
    List<Include>? includes,
    Map<ChapterOrders, OrderDirections>? orders,
  }) {
    return SearchChapterParameterDeprecated(
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      mangaId: mangaId ?? this.mangaId,
      title: title ?? this.title,
      uploader: uploader ?? this.uploader,
      volume: volume ?? this.volume,
      chapter: chapter ?? this.chapter,
      createdAtSince: createdAtSince ?? this.createdAtSince,
      updatedAtSince: updatedAtSince ?? this.updatedAtSince,
      publishedAtSince: publishedAtSince ?? this.publishedAtSince,
      ids: ids ?? this.ids,
      groups: groups ?? this.groups,
      translatedLanguage: translatedLanguage ?? this.translatedLanguage,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      excludedOriginalLanguage:
          excludedOriginalLanguage ?? this.excludedOriginalLanguage,
      contentRating: contentRating ?? this.contentRating,
      includes: includes ?? this.includes,
      orders: orders ?? this.orders,
    );
  }
}
