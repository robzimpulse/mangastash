import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaTagServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'tags',
  );

  MangaTagServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<MangaTag> add(MangaTag value) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

  Future<MangaTag> update({
    String? key,
    required Future<MangaTag> Function(MangaTag value) update,
    required Future<MangaTag> Function() ifAbsent,
  }) async {
    if (key != null) {
      final data = (await _ref.doc(key).get()).data();
      if (data != null) {
        final updated = await update(MangaTag.fromJson(data));
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

  Future<MangaTag> get(String id) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) throw Exception('Data not Found');
    return MangaTag.fromJson(value);
  }

  Future<List<MangaTag>> list() async {
    return (await _ref.get())
        .docs
        .map((e) => MangaTag.fromJson(e.data()))
        .toList();
  }

  Future<List<MangaTag>> search({
    required List<MangaTag> tags,
  }) async {
    final List<MangaTag> data = [];

    for (final tag in tags.slices(10)) {
      final List<MangaTag> temp = [];
      final names = tag.map((e) => e.name).whereNotNull();
      final ref = _ref.where('name', whereIn: names);
      final total = (await ref.count().get()).count ?? 0;
      String? offset;
      do {
        final docs = (await ref.startAfter([offset]).limit(100).get()).docs;
        offset = docs.lastOrNull?.id;
        temp.addAll(
          docs.map((e) => MangaTag.fromJson(e.data()).copyWith(id: e.id)),
        );
      } while (temp.length < total);
      data.addAll(temp);
    }

    return data;
  }
}
