import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;

  MangaServiceFirebase({required FirebaseApp app})
      : _ref = FirebaseFirestore.instanceFor(app: app).collection('mangas');

  Future<Manga> sync({required Manga value}) async {
    final founds = await search(value: value);

    final match = founds
        .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
        .lastOrNull;

    return await update(
      key: match?.id ?? value.id,
      update: (old) async => value.merge(old),
      ifAbsent: () async => value,
    );
  }

  Future<Manga> add({required Manga value}) async {
    final id = value.id;

    if (id == null) {
      final ref = await _ref.add(value.toJson());
      final data = value.copyWith(id: ref.id);
      await ref.update(data.toJson());
      return data;
    }

    await _ref.doc(id).set(value.toJson());
    return value;
  }

  Future<void> delete({required Manga value}) {
    return _ref.doc(value.id).delete();
  }

  Future<Manga> update({
    required String? key,
    required Future<Manga> Function(Manga value) update,
    required Future<Manga> Function() ifAbsent,
  }) async {
    if (key == null) {
      return add(value: await ifAbsent());
    }

    final data = await get(id: key);
    if (data == null) {
      return add(value: await ifAbsent());
    }

    final updated = await update(data);
    if (updated != data) {
      await _ref.doc(key).set(updated.toJson());
    }
    return updated;
  }

  Future<Manga?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return Manga.fromJson(value).copyWith(id: id);
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
        .where('web_url', isEqualTo: value.webUrl)
        .orderBy('source');

    final total = (await ref.count().get()).count ?? 0;
    DocumentSnapshot? offset;

    do {
      final result = (offset == null)
          ? await (ref.limit(100).get())
          : await (ref.startAfterDocument(offset).limit(100).get());
      data.addAll(
        result.docs.map((e) => Manga.fromJson(e.data()).copyWith(id: e.id)),
      );
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    return data;
  }

  Stream<Manga?> stream({required String id}) {
    final stream = _ref.doc(id).snapshots();
    return stream.map(
      (e) {
        final json = e.data();
        return json == null ? null : Manga.fromJson(json).copyWith(id: e.id);
      },
    );
  }
}
