import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_tags_mixin.dart';

class GetTagsOnMangadexUseCase with SyncTagsMixin {
  final MangaService _mangaService;
  final TagDao _tagDao;
  final LogBox _logBox;

  GetTagsOnMangadexUseCase({
    required MangaService mangaService,
    required TagDao tagDao,
    required LogBox logBox,
  })  : _mangaService = mangaService,
        _tagDao = tagDao,
        _logBox = logBox;

  Future<Result<List<Tag>>> execute() async {
    try {
      final result = await _mangaService.tags();

      final tags = result.data;

      if (tags == null) {
        return Error(Exception('Tag not found'));
      }

      final process = await sync(
        logBox: _logBox,
        dao: _tagDao,
        values: [
          for (final tag in tags)
            Tag.from(data: tag).copyWith(source: Source.mangadex().name),
        ],
      );

      return Success(process);
    } catch (e) {
      return Error(e);
    }
  }
}
