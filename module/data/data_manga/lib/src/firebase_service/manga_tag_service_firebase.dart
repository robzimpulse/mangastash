import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaTagServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;

  MangaTagServiceFirebase({required FirebaseApp app})
      : _ref = FirebaseFirestore.instanceFor(app: app).collection('tags');

  Future<MangaTag> sync({required MangaTag value}) async {
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

  Future<MangaTag> add({required MangaTag value}) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

  Future<MangaTag> update({
    required String? key,
    required Future<MangaTag> Function(MangaTag value) update,
    required Future<MangaTag> Function() ifAbsent,
  }) async {
    if (key == null) return add(value: await ifAbsent());
    final data = (await _ref.doc(key).get()).data();
    if (data == null) {
      final value = (await ifAbsent()).copyWith(id: key);
      await _ref.doc(key).set(value.copyWith(id: key).toJson());
      return value;
    }
    final updated = await update(MangaTag.fromJson(data));
    if (updated.toJson() == data) return updated;
    await _ref.doc(key).set(updated.copyWith(id: key).toJson());
    return updated.copyWith(id: key);
  }

  Future<List<MangaTag>> search({
    required MangaTag value,
  }) async {
    final List<MangaTag> data = [];
    final ref = _ref.where('name', isEqualTo: value.name).orderBy('name');
    final total = (await ref.count().get()).count ?? 0;
    DocumentSnapshot? offset;

    do {
      final result = (offset == null)
          ? await (ref.limit(100).get())
          : await (ref.startAfterDocument(offset).limit(100).get());
      data.addAll(result.docs.map((e) => MangaTag.fromJson(e.data())));
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    return data;
  }
}
