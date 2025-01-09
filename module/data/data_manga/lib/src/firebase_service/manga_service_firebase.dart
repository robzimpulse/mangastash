import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'mangas',
  );

  MangaServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<Manga> add(Manga value) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

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

    return add(await ifAbsent());
  }

  Future<Manga?> get(String id) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return Manga.fromJson(value);
  }

  Future<List<Manga>> search({
    required List<Manga> mangas,
  }) async {
    final List<Manga> data = [];

    for (final item in mangas) {
      final List<Manga> temp = [];
      final ref = _ref
          .where('title', isEqualTo: item.title)
          .where('cover_url', isEqualTo: item.coverUrl)
          .where('author', isEqualTo: item.author)
          .where('status', isEqualTo: item.status)
          .where('description', isEqualTo: item.description)
          .where('source', isEqualTo: item.source?.value)
          .where('web_url', isEqualTo: item.webUrl)
          .orderBy('source');

      final total = (await ref.count().get()).count ?? 0;
      String? offset;

      do {
        final query = await ref.startAfter([offset]).limit(100).get();
        offset = query.docs.lastOrNull?.id;
        temp.addAll(query.docs.map((e) => Manga.fromJson(e.data())));
      } while (temp.length < total);
      data.addAll(temp);
    }

    return data;
  }
}
