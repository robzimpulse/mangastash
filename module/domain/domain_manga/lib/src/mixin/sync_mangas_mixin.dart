import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncMangasMixin {
  Future<List<Manga>> sync({
    required MangaDao dao,
    required List<Manga> values,
    required LogBox logBox,
  }) async {

    final results = await dao.adds(
      values: {
        for (final value in values)
          value.toDrift: [...?value.tags?.map((e) => e.name).nonNulls],
      },
    );

    final data = [...results.map((e) => Manga.fromDatabase(e)).nonNulls];

    logBox.log(
      'Insert & Update Manga',
      extra: {
        'before count': values.length,
        'after count': data.length,
        'before data': [...values.map((e) => e.toJson())],
        'after data': [...data.map((e) => e.toJson())],
      },
      name: 'Sync Process',
    );

    return data;
  }
}
