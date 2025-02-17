import 'package:domain_manga/domain_manga.dart';
import 'package:equatable/equatable.dart';

class MangaSearchParamConfiguratorScreenState extends Equatable {
  final bool hasAvailableChapters;
  final Map<LanguageCodes, bool?> originalLanguage;
  final List<ContentRating> contentRating;
  final List<PublicDemographic>? publicationDemographic;
  final List<MangaStatus>? status;
  final SearchOrders? orderBy;
  final OrderDirections? orderDirection;
  final List<String>? includedTags;
  final TagsMode? includedTagsMode;
  final List<String>? excludedTags;
  final TagsMode? excludedTagsMode;

  const MangaSearchParamConfiguratorScreenState({
    this.hasAvailableChapters = false,
    this.originalLanguage = const {},
    this.contentRating = const [],
    this.publicationDemographic,
    this.status,
    this.orderBy,
    this.orderDirection,
    this.includedTags,
    this.includedTagsMode,
    this.excludedTags,
    this.excludedTagsMode,
  });

  @override
  List<Object?> get props => [
        hasAvailableChapters,
        originalLanguage,
        contentRating,
        publicationDemographic,
        status,
        orderBy,
        orderDirection,
        includedTags,
        includedTagsMode,
        excludedTags,
        excludedTagsMode,
      ];

  MangaSearchParamConfiguratorScreenState copyWith({
    bool? hasAvailableChapters,
    Map<LanguageCodes, bool?>? originalLanguage,
    List<ContentRating>? contentRating,
    List<PublicDemographic>? publicationDemographic,
    List<MangaStatus>? status,
    SearchOrders? orderBy,
    OrderDirections? orderDirection,
    List<String>? includedTags,
    TagsMode? includedTagsMode,
    List<String>? excludedTags,
    TagsMode? excludedTagsMode,
  }) {
    return MangaSearchParamConfiguratorScreenState(
      hasAvailableChapters: hasAvailableChapters ?? this.hasAvailableChapters,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      contentRating: contentRating ?? this.contentRating,
      publicationDemographic:
          publicationDemographic ?? this.publicationDemographic,
      status: status ?? this.status,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
      includedTags: includedTags ?? this.includedTags,
      includedTagsMode: includedTagsMode ?? this.includedTagsMode,
      excludedTags: excludedTags ?? this.excludedTags,
      excludedTagsMode: excludedTagsMode ?? this.excludedTagsMode,
    );
  }
}
