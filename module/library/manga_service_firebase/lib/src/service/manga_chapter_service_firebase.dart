import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../model/manga_chapter_firebase.dart';
import '../util/typedef.dart';

class MangaChapterServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;
  final LoggerCallback? _logger;

  MangaChapterServiceFirebase({
    required FirebaseApp app,
    LoggerCallback? logger,
  })  : _ref = FirebaseFirestore.instanceFor(app: app).collection('chapters'),
        _logger = logger;

  // Future<MangaChapterFirebase> sync({
  //   required MangaChapterFirebase value,
  // }) async {
  //   final founds = await search(value: value);
  //
  //   final match = founds
  //       .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
  //       .lastOrNull;
  //
  //   if (founds.length > 1) {
  //     _logger?.call(
  //       'Duplicate entry',
  //       extra: {
  //         'value': value.toJson(),
  //         'match': match?.toJson(),
  //         'similarity': value.similarity(match),
  //         'duplicated': founds.map((e) => e.toJson()).toList(),
  //       },
  //       name: runtimeType.toString(),
  //     );
  //   }
  //
  //   return await update(
  //     key: match?.id ?? value.id,
  //     update: (old) async => value.merge(old),
  //     ifAbsent: () async => value,
  //   );
  // }

  Future<MangaChapterFirebase> add({
    required MangaChapterFirebase value,
  }) async {
    final id = value.id;

    if (id == null) {
      final ref = await _ref.add(value.toJson());
      final data = value.copyWith(id: ref.id);
      await ref.update(data.toJson());

      _logger?.call(
        'Add new entry',
        extra: {'value': data.toJson()},
        name: runtimeType.toString(),
      );

      return data;
    }

    _logger?.call(
      'Update new entry',
      extra: {'value': value.toJson()},
      name: runtimeType.toString(),
    );

    await _ref.doc(id).set(value.toJson());
    return value;
  }

  Future<MangaChapterFirebase?> get({required String id}) async {
    final value = await _ref.doc(id).get();
    final data = value.data();
    _logger?.call(
      'Get entry',
      extra: {'value': data},
      name: runtimeType.toString(),
    );
    if (data == null) return null;
    return MangaChapterFirebase.fromFirebase(value);
  }

  Future<MangaChapterFirebase> update({
    required String? key,
    required AsyncValueUpdater<MangaChapterFirebase> update,
    required AsyncValueGetter<MangaChapterFirebase> ifAbsent,
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
      _logger?.call(
        'Update existing entry',
        extra: {
          'value': data.toJson(),
          'updated': updated.toJson(),
        },
        name: runtimeType.toString(),
      );
      await _ref.doc(key).set(updated.toJson());
    }
    return updated;
  }

  Future<List<MangaChapterFirebase>> search({
    required MangaChapterFirebase value,
  }) async {
    final List<MangaChapterFirebase> data = [];

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
      data.addAll(
        result.docs.map(
          (e) => MangaChapterFirebase.fromFirebase(e),
        ),
      );
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    _logger?.call(
      'Search existing entry',
      extra: {
        'value': value.toJson(),
        'matched': data.map((e) => e.toJson()).toList(),
      },
      name: runtimeType.toString(),
    );

    return data;
  }
}
