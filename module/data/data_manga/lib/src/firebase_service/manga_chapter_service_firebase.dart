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

  Future<List<MangaChapter>> sync({required List<MangaChapter> values}) async {
    final cache = await Future.wait(values.map((e) => search(value: e)));
    final oldValues = cache.expand((e) => e);
    final ids = Set.of(oldValues.map((e) => e.webUrl).whereNotNull());
    final diff = List.of(values);
    diff.removeWhere((e) => ids.contains(e.webUrl));
    final newValues = await Future.wait(diff.map((e) => add(value: e)));
    return [...oldValues, ...newValues];
  }

  Future<MangaChapter> add({required MangaChapter value}) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

  // Future<void> update(MangaChapter value) async {
  //   await _ref.doc(value.id).set(value.toJson());
  // }
  //
  // Future<bool> exists(String id) async {
  //   return (await _ref.doc(id).get()).exists;
  // }
  //
  Future<MangaChapter?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) return null;
    return MangaChapter.fromJson(value);
  }

  Future<MangaChapter> update({
    required String key,
    required Future<MangaChapter> Function(MangaChapter value) update,
    required Future<MangaChapter> Function() ifAbsent,
  }) async {
    final data = (await _ref.doc(key).get()).data();
    if (data != null) {
      final updated = await update(MangaChapter.fromJson(data));
      if (updated.toJson() == data) return updated;
      await _ref.doc(key).set(updated.toJson());
      return updated;
    }
    final newData = (await ifAbsent()).copyWith(id: key);
    await _ref.doc(key).set(newData.toJson());
    return newData;
  }

  //
  // Future<Result<List<MangaChapter>>> list() async {
  //   final value = await _ref.get();
  //   final data = value.docs.map((e) => MangaChapter.fromJson(e.data())).toList();
  //   return Success(data);
  // }
  //

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

  // Future<Result<Pagination<MangaChapter>>> search({
  //   String? mangaId,
  //   String? title,
  //   String? volume,
  //   String? chapter,
  //   String? readableAt,
  //   int limit = 30,
  //   int? offset,
  // }) async {
  //   Query<Map<String, dynamic>> queries = _ref;
  //
  //   if (title != null) {
  //     queries = queries.where('title', isEqualTo: title);
  //   }
  //
  //   if (mangaId != null) {
  //     queries = queries.where('mangaId', isEqualTo: mangaId);
  //   }
  //
  //   if (volume != null) {
  //     queries = queries.where('volume', isEqualTo: volume);
  //   }
  //
  //   if (readableAt != null) {
  //     queries = queries.where('readableAt', isEqualTo: readableAt);
  //   }
  //
  //   if (chapter != null) {
  //     queries = queries.where('chapter', isEqualTo: chapter);
  //   }
  //
  //   if (offset != null) {
  //     queries = queries.startAfter([offset]);
  //   }
  //
  //   final count = await queries.count().get();
  //   final data = await queries.limit(limit).get();
  //
  //   return Success(
  //     Pagination<MangaChapter>(
  //       data: data.docs
  //           .map((e) => MangaChapter.fromJson(e.data()).copyWith(id: e.id))
  //           .toList(),
  //       limit: limit,
  //       offset: data.docs.lastOrNull?.id,
  //       total: count.count,
  //     ),
  //   );
  // }
}
