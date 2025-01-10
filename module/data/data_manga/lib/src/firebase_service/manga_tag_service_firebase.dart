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

  Future<List<MangaTag>> sync(List<MangaTag> tags) async {
    final cache = await Future.wait(tags.map((tag) => search(tag: tag)));
    final oldTags = cache.expand((e) => e);
    final names = Set.of(oldTags.map((tag) => tag.name).whereNotNull());
    final diff = List.of(tags)..removeWhere((tag) => names.contains(tag.name));
    final newTags = await Future.wait(diff.map((tag) => add(tag)));
    return [...oldTags, ...newTags];
  }

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

    return add(await ifAbsent());
  }

  Future<MangaTag?> get(String id) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return MangaTag.fromJson(value);
  }

  Future<List<MangaTag>> search({
    required MangaTag tag,
  }) async {
    final List<MangaTag> data = [];
    final ref = _ref.where('name', isEqualTo: tag.name).orderBy('name');
    final total = (await ref.count().get()).count ?? 0;
    String? offset;

    do {
      final query = await ref.startAfter([offset]).limit(100).get();
      offset = query.docs.lastOrNull?.id;
      data.addAll(query.docs.map((e) => MangaTag.fromJson(e.data())));
    } while (data.length < total);

    return data;
  }
}
