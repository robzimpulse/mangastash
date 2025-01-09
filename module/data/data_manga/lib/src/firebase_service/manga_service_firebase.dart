import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'mangas',
  );

  MangaServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<Manga> update({
    String? key,
    required Future<Manga> Function(Manga value) update,
    required Future<Manga> Function() ifAbsent,
  }) async {
    if (key != null) {
      final data = (await _ref.doc(key).get()).data();
      if (data != null) {
        final updated = await update(Manga.fromJson(data));
        if (updated.toJson() == data) return updated;
        await _ref.doc(key).set(updated.toJson());
        return updated;
      }
      final newData = (await ifAbsent()).copyWith(id: key);
      await _ref.doc(key).set(newData.toJson());
      return newData;
    }

    final id = (await _ref.add({})).id;
    final newData = (await ifAbsent()).copyWith(id: id);
    await _ref.doc(id).set(newData.toJson());
    return newData;
  }

  Future<Manga> get(String id) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) throw Exception('Data not Found');
    return Manga.fromJson(value);
  }

  // Future<List<Manga>> search({
  //   required List<Manga> mangas,
  // }) async {
  //   final List<Manga> data = [];
  //
  //   for (final manga in mangas.slices(10)) {
  //     for (final item in manga) {
  //       final List<Manga> temp = [];
  //       Query<Map<String, dynamic>> ref = _ref;
  //       if (item.title != null) {
  //         ref = ref.where('title', isEqualTo: item.title);
  //       }
  //       if (item.coverUrl != null) {
  //         ref = ref.where('coverUrl', isEqualTo: item.coverUrl);
  //       }
  //       if (item.author != null) {
  //         ref = ref.where('author', isEqualTo: item.author);
  //       }
  //       if (item.status != null) {
  //         ref = ref.where('status', isEqualTo: item.status);
  //       }
  //       if (item.description != null) {
  //         ref = ref.where('description', isEqualTo: item.description);
  //       }
  //       if (item.source != null) {
  //         ref = ref.where('source', isEqualTo: item.source?.value);
  //       }
  //       if (item.webUrl != null) {
  //         ref = ref.where('web_url', isEqualTo: item.webUrl);
  //       }
  //
  //       final total = (await ref.count().get()).count ?? 0;
  //       String? offset;
  //
  //       do {
  //         final query =
  //             await ref.orderBy('title').startAfter([offset]).limit(100).get();
  //         offset = query.docs.lastOrNull?.id;
  //         temp.addAll(
  //           query.docs.map((e) => Manga.fromJson(e.data()).copyWith(id: e.id)),
  //         );
  //       } while (temp.length < total);
  //       data.addAll(temp);
  //     }
  //   }
  //
  //   return data;
  // }
}
