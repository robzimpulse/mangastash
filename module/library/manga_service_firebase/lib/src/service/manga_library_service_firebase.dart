import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../util/typedef.dart';

class MangaLibraryServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;
  final LoggerCallback? _logger;

  MangaLibraryServiceFirebase({
    required FirebaseApp app,
    LoggerCallback? logger,
  })  : _ref = FirebaseFirestore.instanceFor(app: app).collection('libraries'),
        _logger = logger;

  Future<bool> add({required String mangaId, required String userId}) async {
    _logger?.call(
      'Add Manga to library',
      extra: {'mangaId': mangaId, 'userId': userId},
      name: runtimeType.toString(),
    );
    final libraries = await _get(userId: userId);
    if (libraries.contains(mangaId)) return true;
    await _ref.doc(userId).set(
      {
        for (final (index, value) in [mangaId, ...libraries].indexed)
          '$index': value,
      },
    );
    return true;
  }

  Future<bool> remove({required String mangaId, required String userId}) async {
    _logger?.call(
      'Remove Manga from library',
      extra: {'mangaId': mangaId, 'userId': userId},
      name: runtimeType.toString(),
    );
    final libraries = await _get(userId: userId);
    if (!libraries.contains(mangaId)) return true;
    final newList = [...libraries]..remove(mangaId);
    await _ref.doc(userId).set(
      {
        for (final (index, value) in newList.indexed) '$index': value,
      },
    );
    return true;
  }

  Future<List<String>> _get({required String userId}) async {
    final values = (await _ref.doc(userId).get()).data();
    if (values == null) return [];
    return values.values.whereType<String>().toList();
  }

  Stream<List<String>> stream({required String userId}) {
    final stream = _ref.doc(userId).snapshots();
    return stream.map(
      (event) => [...?event.data()?.values.whereType<String>()],
    );
  }
}
