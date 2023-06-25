// import 'package:mangadex_library/enums/content_rating.dart';
// import 'package:mangadex_library/enums/language_codes.dart';
// import 'package:mangadex_library/enums/manga_status.dart';
// import 'package:mangadex_library/enums/order_enums.dart';
// import 'package:mangadex_library/enums/publication_demographic.dart';
// import 'package:mangadex_library/enums/tag_modes.dart';
// import 'package:mangadex_library/mangadex_library.dart' as lib;
// import 'package:mangadex_library/models/chapter/chapter_data.dart';
// import 'package:mangadex_library/models/common/base_url.dart';
// import 'package:mangadex_library/models/common/single_manga_data.dart';
// import 'package:mangadex_library/models/search/search.dart';
//
// class MangaDexWrapper {
//
//   Future<Search> search({
//     String? query,
//     int? limit,
//     int? offset,
//     List<String>? authors,
//     List<String>? artists,
//     int? year,
//     List<String>? includedTags,
//     TagsMode? includedTagsMode,
//     List<String>? excludedTags,
//     TagsMode? excludedTagsMode,
//     List<MangaStatus>? status,
//     List<LanguageCodes>? originalLanguage,
//     List<LanguageCodes>? excludedOriginalLanguages,
//     List<LanguageCodes>? availableTranslatedLanguage,
//     List<PublicDemographic>? publicationDemographic,
//     List<String>? ids,
//     List<ContentRating>? contentRating,
//     String? createdAtSince, // should be of format DD-MM-YYYY
//     String? updatedAtSince, // should be of format DD-MM-YYYY
//     List<String>? includes,
//     String? group,
//     Map<SearchOrders, OrderDirections>? orders,
//   }) {
//     return lib.search(
//       query: query,
//       limit: limit,
//       offset: offset,
//       authors: authors,
//       artists: artists,
//       year: year,
//       includedTags: includedTags,
//       includedTagsMode: includedTagsMode,
//       excludedTags: excludedTags,
//       excludedTagsMode: excludedTagsMode,
//       status: status,
//       originalLanguage: originalLanguage,
//       excludedOriginalLanguages: excludedOriginalLanguages,
//       availableTranslatedLanguage: availableTranslatedLanguage,
//       publicationDemographic: publicationDemographic,
//       ids: ids,
//       contentRating: contentRating,
//       createdAtSince: createdAtSince,
//       updatedAtSince: updatedAtSince,
//       includes: includes,
//       group: group,
//       orders: orders,
//     );
//   }
//
//   Future<SingleMangaData> manga(String mangaId) {
//     return lib.getMangaDataByMangaId(mangaId);
//   }
//
//   Future<ChapterData> chapters({
//     required String mangaId,
//     List<String>? ids,
//     String? title,
//     List<String>? groups,
//     String? uploader,
//     String? volume,
//     String? chapter,
//     List<LanguageCodes>? translatedLanguage,
//     List<LanguageCodes>? originalLanguage,
//     List<LanguageCodes>? excludedOriginalLanguage,
//     List<ContentRating>? contentRating,
//     String? createdAtSince,
//     String? updatedAtSince,
//     String? publishedAtSince,
//     String? includes,
//     Map<ChapterOrders, OrderDirections>? orders,
//     int? limit,
//     int? offset,
//   }) {
//     return lib.getChapters(
//       mangaId,
//       ids: ids,
//       title: title,
//       groups: groups,
//       uploader: uploader,
//       volume: volume,
//       chapter: chapter,
//       translatedLanguage: translatedLanguage,
//       originalLanguage: originalLanguage,
//       excludedOriginalLanguage: excludedOriginalLanguage,
//       contentRating: contentRating,
//       createdAtSince: createdAtSince,
//       updatedAtSince: updatedAtSince,
//       publishedAtSince: publishedAtSince,
//       includes: includes,
//       orders: orders,
//       limit: limit,
//       offset: offset,
//     );
//   }
//
//   Future<BaseUrl> url({required String chapterId}) {
//     return lib.getBaseUrl(chapterId);
//   }
//
//   String page({
//     required String baseUrl,
//     required bool dataSaver,
//     required String chapterHash,
//     required String filename,
//   }) => lib.constructPageUrl(baseUrl, dataSaver, chapterHash, filename);
// }
