import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaLibraryServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'libraries',
  );

  MangaLibraryServiceFirebase({
    required FirebaseApp app,
  }) : _app = app;

  Future<Result<bool>> add(Manga value, String userId) async {
    await _ref.doc(userId).set(value.toJson());
    return Success(true);
  }

  // Future<void> update(Manga value) async {
  //   await _ref.doc(value.id).set(value.toJson());
  // }
  //
  // Future<bool> exists(String id) async {
  //   return (await _ref.doc(id).get()).exists;
  // }
  //
  // Future<Manga> get(String id) async {
  //   final value = (await _ref.doc(id).get()).data();
  //   if (value == null) throw Exception('Data not Found');
  //   return Manga.fromJson(value);
  // }
  //
  // Future<Result<List<Manga>>> list() async {
  //   final value = await _ref.get();
  //   final data = value.docs.map((e) => Manga.fromJson(e.data())).toList();
  //   return Success(data);
  // }
  //
  // Future<Result<Pagination<Manga>>> search({
  //   String? title,
  //   String? coverUrl,
  //   String? author,
  //   String? status,
  //   String? description,
  //   MangaSourceEnum? source,
  //   int limit = 30,
  //   int? offset,
  // }) async {
  //   Query<Map<String, dynamic>> queries = _ref;
  //
  //   if (title != null) {
  //     queries = queries.where('title', isEqualTo: title);
  //   }
  //
  //   if (coverUrl != null) {
  //     queries = queries.where('coverUrl', isEqualTo: coverUrl);
  //   }
  //
  //   if (author != null) {
  //     queries = queries.where('author', isEqualTo: author);
  //   }
  //
  //   if (status != null) {
  //     queries = queries.where('status', isEqualTo: status);
  //   }
  //
  //   if (description != null) {
  //     queries = queries.where('description', isEqualTo: description);
  //   }
  //
  //   if (source != null) {
  //     queries = queries.where('source', isEqualTo: source.value);
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
  //     Pagination<Manga>(
  //       data: data.docs
  //           .map((e) => Manga.fromJson(e.data()).copyWith(id: e.id))
  //           .toList(),
  //       limit: limit,
  //       offset: data.docs.lastOrNull?.id,
  //       total: count.count,
  //     ),
  //   );
  // }
}
