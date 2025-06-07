import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncChaptersMixin {
  Future<List<Chapter>> sync({
    required ChapterDao chapterDao,
    required List<Chapter> values,
    required LogBox logBox,
  }) async {
    final results = await chapterDao.adds(
      values: {
        for (final value in values) value.toDrift: [...?value.images],
      },
    );

    final data = [...results.map((e) => Chapter.fromDatabase(e)).nonNulls];

    logBox.log(
      'Insert & Update Chapter',
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
