import 'package:core_storage/core_storage.dart';
import 'package:mocktail/mocktail.dart';

class FakeImageCacheManager extends Mock implements ImageCacheManager {}

class FakeConverterCacheManager extends Mock implements ConverterCacheManager {}

class FakeTagCacheManager extends Mock implements TagCacheManager {}

class FakeMangaCacheManager extends Mock implements MangaCacheManager {}

class FakeChapterCacheManager extends Mock implements ChapterCacheManager {}

class FakeHtmlCacheManager extends Mock implements HtmlCacheManager {}

class FakeSearchChapterCacheManager extends Mock
    implements SearchChapterCacheManager {}

class FakeSearchMangaCacheManager extends Mock
    implements SearchMangaCacheManager {}
