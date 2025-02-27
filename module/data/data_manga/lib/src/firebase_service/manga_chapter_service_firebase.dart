import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaChapterServiceFirebase {
  final FirebaseApp _app;

  late final _db = FirebaseFirestore.instanceFor(app: _app);

  late final _ref = _db.collection('chapters');

  late final _stream = _ref.snapshots();

  MangaChapterServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<MangaChapter> sync({required MangaChapter value}) async {
    final founds = await search(value: value);

    final match = founds
        .where((a) => value.similarity(a) > 0.9)
        .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
        .lastOrNull;

    final candidate = match ?? await add(value: value);

    return await update(
      key: candidate.id,
      update: (old) async => candidate,
      ifAbsent: () async => candidate,
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
    if (key == null) {
      return add(value: await ifAbsent());
    }
    final data = (await _ref.doc(key).get()).data();
    if (data == null) {
      final value = (await ifAbsent()).copyWith(id: key);
      await _ref.doc(key).set(value.toJson());
      return value;
    }
    final updated = await update(MangaChapter.fromJson(data));
    if (updated.toJson() == data) return updated;
    await _ref.doc(key).set(updated.toJson());
    return updated;
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
    String? offset;

    do {
      final query = await ref.startAfter([offset]).limit(100).get();
      offset = query.docs.lastOrNull?.id;
      data.addAll(query.docs.map((e) => MangaChapter.fromJson(e.data())));
    } while (data.length < total);

    return data;
  }
}
