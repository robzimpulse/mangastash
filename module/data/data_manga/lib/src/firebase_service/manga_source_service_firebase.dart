import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaSourceServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;

  MangaSourceServiceFirebase({required FirebaseApp app})
      : _ref = FirebaseFirestore.instanceFor(app: app).collection('sources');

  Stream<List<MangaSource>> stream() {
    return _ref.snapshots().map(
          (event) => List.of(
            event.docs.map(
              (doc) => MangaSource.fromJson(doc.data()).copyWith(id: doc.id),
            ),
          ),
        );
  }
}
