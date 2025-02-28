import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaServiceFirebase {
  final FirebaseApp _app;

  late final _db = FirebaseFirestore.instanceFor(app: _app);

  late final _ref = _db.collection('mangas');

  MangaServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<Manga> sync({required Manga value}) async {
    final founds = await search(value: value);

    final match = founds
        .where((a) => value.similarity(a) > 0.9)
        .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
        .lastOrNull;

    return await update(
      key: match?.id,
      update: (old) async => value,
      ifAbsent: () async => value,
    );
  }

  Future<Manga> add({required Manga value}) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

  Future<void> delete({required Manga value}) {
    return _ref.doc(value.id).delete();
  }

  Future<Manga> update({
    required String? key,
    required Future<Manga> Function(Manga value) update,
    required Future<Manga> Function() ifAbsent,
  }) async {
    if (key == null) return add(value: await ifAbsent());
    final data = (await _ref.doc(key).get()).data();
    if (data == null) {
      final value = (await ifAbsent()).copyWith(id: key);
      await _ref.doc(key).set(value.copyWith(id: key).toJson());
      return value;
    }
    final updated = await update(Manga.fromJson(data));
    if (updated.toJson() == data) return updated;
    await _ref.doc(key).set(updated.copyWith(id: key).toJson());
    return updated.copyWith(id: key);
  }

  Future<Manga?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return Manga.fromJson(value);
  }

  Future<List<Manga>> search({
    required Manga value,
  }) async {
    final List<Manga> data = [];

    final ref = _ref
        .where('title', isEqualTo: value.title)
        .where('cover_url', isEqualTo: value.coverUrl)
        .where('author', isEqualTo: value.author)
        .where('status', isEqualTo: value.status)
        .where('description', isEqualTo: value.description)
        .where('source', isEqualTo: value.source?.value)
        .orderBy('source');

    final total = (await ref.count().get()).count ?? 0;
    DocumentSnapshot? offset;

    do {
      final result = (offset == null)
          ? await (ref.limit(100).get())
          : await (ref.startAfterDocument(offset).limit(100).get());
      data.addAll(result.docs.map((e) => Manga.fromJson(e.data())));
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    return data;
  }
}
