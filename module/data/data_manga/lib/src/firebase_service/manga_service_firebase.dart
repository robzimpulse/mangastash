import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
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
    final manga = value.copyWith(id: ref.id);
    await ref.update(manga.toJson());
    return manga;
  }

  Future<Manga> update(Manga value) async {
    await _ref.doc(value.id).set(value.toJson());
    return value;
  }

  Future<bool> exists(String id) async {
    return (await _ref.doc(id).get()).exists;
  }

  Future<Manga> get(String id) async {
    final value = (await _ref.doc(id).get()).data();
    if (value == null) throw Exception('Data not Found');
    return Manga.fromJson(value);
  }

  Future<List<Manga>> list() async {
    final value = await _ref.get();
    return value.docs.map((e) => Manga.fromJson(e.data())).toList();
  }

  Future<Pagination<Manga>> search({
    List<String>? title,
    List<String>? coverUrl,
    List<String>? author,
    List<String>? status,
    List<String>? description,
    List<String>? webUrl,
    List<MangaSourceEnum>? source,
    int limit = 30,
    int? offset,
  }) async {
    Query<Map<String, dynamic>> queries = _ref;

    if (title != null) {
      queries = queries.where('title', whereIn: title);
    }

    if (coverUrl != null) {
      queries = queries.where('coverUrl', whereIn: coverUrl);
    }

    if (author != null) {
      queries = queries.where('author', whereIn: author);
    }

    if (status != null) {
      queries = queries.where('status', whereIn: status);
    }

    if (description != null) {
      queries = queries.where('description', whereIn: description);
    }

    if (source != null) {
      queries = queries.where('source', whereIn: source.map((e) => e.value));
    }

    if (webUrl != null) {
      queries = queries.where('web_url', whereIn: webUrl);
    }

    if (offset != null) {
      queries = queries.startAfter([offset]);
    }

    final count = await queries.count().get();
    final data = await queries.limit(limit).get();

    return Pagination(
      data: data.docs
          .map((e) => Manga.fromJson(e.data()).copyWith(id: e.id))
          .toList(),
      limit: limit,
      offset: data.docs.lastOrNull?.id,
      total: count.count,
    );
  }
}
