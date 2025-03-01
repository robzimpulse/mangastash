import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:log_box/log_box.dart';

class MangaChapterServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;
  final LogBox _logBox;

  MangaChapterServiceFirebase({
    required FirebaseApp app,
    required LogBox logBox,
  })  : _ref = FirebaseFirestore.instanceFor(app: app).collection('chapters'),
        _logBox = logBox;

  Future<MangaChapter> sync({required MangaChapter value}) async {
    final founds = await search(value: value);

    if (founds.length > 1) {
      _logBox.log(
        'Duplicate `MangaChapter` entry',
        extra: {
          'value': value.toJson(),
          'duplicated': founds.map((e) => e.toJson()).toList(),
        },
        name: 'MangaChapterServiceFirebase',
      );
    }

    final match = founds
        .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
        .lastOrNull;

    return await update(
      key: match?.id ?? value.id,
      update: (old) async => value.merge(old),
      ifAbsent: () async => value,
    );
  }

  Future<MangaChapter> add({required MangaChapter value}) async {
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

  Future<MangaChapter?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return MangaChapter.fromJson(value).copyWith(id: id);
  }

  Future<MangaChapter> update({
    required String? key,
    required Future<MangaChapter> Function(MangaChapter value) update,
    required Future<MangaChapter> Function() ifAbsent,
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

  Future<List<MangaChapter>> search({
    required MangaChapter value,
  }) async {
    final List<MangaChapter> data = [];

    final ref = _ref
        .where('manga_id', isEqualTo: value.mangaId)
        .where('manga_title', isEqualTo: value.mangaTitle)
        .where('chapter', isEqualTo: value.chapter)
        .orderBy('manga_id');

    final total = (await ref.count().get()).count ?? 0;
    DocumentSnapshot? offset;

    do {
      final result = (offset == null)
          ? await (ref.limit(100).get())
          : await (ref.startAfterDocument(offset).limit(100).get());
      data.addAll(result.docs
          .map((e) => MangaChapter.fromJson(e.data()).copyWith(id: e.id)));
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    return data;
  }
}
