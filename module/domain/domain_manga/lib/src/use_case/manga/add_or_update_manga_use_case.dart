import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

// class AddOrUpdateMangaUseCase {
//   final MangaServiceFirebase _mangaServiceFirebase;
//   final MangaTagServiceFirebase _mangaTagServiceFirebase;
//
//   AddOrUpdateMangaUseCase({
//     required MangaServiceFirebase mangaServiceFirebase,
//     required MangaTagServiceFirebase mangaTagServiceFirebase,
//   })  : _mangaServiceFirebase = mangaServiceFirebase,
//         _mangaTagServiceFirebase = mangaTagServiceFirebase;
//
//   Future<void> execute({required List<Manga> data}) async {
//     for (final manga in data) {
//       for (final tag in manga.tags ?? []) {
//         final id = tag.id;
//         if (id == null) continue;
//         final isExists = await _mangaTagServiceFirebase.exists(id);
//         if (isExists) {
//           await _mangaTagServiceFirebase.update(tag);
//         } else {
//           await _mangaTagServiceFirebase.add(tag);
//         }
//       }
//
//       final id = manga.id;
//       if (id == null) return;
//       final isExists = await _mangaServiceFirebase.exists(id);
//       if (isExists) {
//         await _mangaServiceFirebase.update(manga);
//       } else {
//         await _mangaServiceFirebase.add(manga);
//       }
//     }
//   }
// }
