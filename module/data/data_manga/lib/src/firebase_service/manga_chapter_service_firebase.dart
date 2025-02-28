import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaChapterServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;

  MangaChapterServiceFirebase({required FirebaseApp app})
      : _ref = FirebaseFirestore.instanceFor(app: app).collection('chapters');

  Future<MangaChapter> sync({required MangaChapter value}) async {
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

  Future<MangaChapter> add({required MangaChapter value}) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

  Future<MangaChapter?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return MangaChapter.fromJson(value);
  }

  Future<MangaChapter> update({
    required String? key,
    required Future<MangaChapter> Function(MangaChapter value) update,
    required Future<MangaChapter> Function() ifAbsent,
  }) async {
    if (key == null) return add(value: await ifAbsent());
    final data = (await _ref.doc(key).get()).data();
    if (data == null) {
      final value = (await ifAbsent()).copyWith(id: key);
      await _ref.doc(key).set(value.copyWith(id: key).toJson());
      return value;
    }
    final updated = await update(MangaChapter.fromJson(data));
    if (updated.toJson() == data) return updated;
    await _ref.doc(key).set(updated.copyWith(id: key).toJson());
    return updated.copyWith(id: key);
  }

  Future<List<MangaChapter>> search({
    required MangaChapter value,
  }) async {
    final List<MangaChapter> data = [];

    final ref = _ref
        .where('manga_id', isEqualTo: value.mangaId)
        .where('manga_title', isEqualTo: value.mangaTitle)
        .where('volume', isEqualTo: value.volume)
        .where('chapter', isEqualTo: value.chapter)
        .where('readable_at', isEqualTo: value.readableAt)
        .where('publish_at', isEqualTo: value.publishAt)
        .where('translated_language', isEqualTo: value.translatedLanguage)
        .where('scanlation_group', isEqualTo: value.scanlationGroup)
        .where('web_url', isEqualTo: value.webUrl)
        .orderBy('manga_id');

    final total = (await ref.count().get()).count ?? 0;
    DocumentSnapshot? offset;

    do {
      final result = (offset == null)
          ? await (ref.limit(100).get())
          : await (ref.startAfterDocument(offset).limit(100).get());
      data.addAll(result.docs.map((e) => MangaChapter.fromJson(e.data())));
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    return data;
  }
}
