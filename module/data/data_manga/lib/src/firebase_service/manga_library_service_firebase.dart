import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
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

  Future<bool> add(Manga value, String userId) async {
    final existing = (await get(userId));
    final isExists = existing.firstWhereOrNull((e) => e.id == value.id) != null;
    if (isExists) return true;
    await _ref.doc(userId).set(
      {
        for (final (index, value) in [...existing, value].indexed)
          '$index': value.toJson(),
      },
    );
    return true;
  }

  Future<bool> remove(Manga value, String userId) async {
    final existing = (await get(userId));
    final isExists = existing.firstWhereOrNull((e) => e.id == value.id) != null;
    if (!isExists) return true;
    final newList = [...existing]..removeWhere((e) => e.id == value.id);
    await _ref.doc(userId).set(
      {
        for (final (index, value) in newList.indexed) '$index': value.toJson(),
      },
    );
    return true;
  }

  Future<bool> exists(Manga value, String userId) async {
    final existing = (await get(userId));
    return existing.firstWhereOrNull((e) => e.id == value.id) != null;
  }

  Future<List<Manga>> get(String userId) async {
    final values = (await _ref.doc(userId).get()).data();
    if (values == null) return [];
    return [
      for (final value in values.entries) Manga.fromJson(value.value),
    ];
  }

  Stream<List<Manga>> listen(String userId) {
    final stream = _ref.doc(userId).snapshots();
    return stream.map((event) {
      final values = event.data();
      if (values == null) return [];
      return [for (final value in values.entries) Manga.fromJson(value.value)];
    });
  }
}
