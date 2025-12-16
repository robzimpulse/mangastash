import 'package:core_storage/core_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockImagesCacheManager extends Mock implements ImagesCacheManager {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockTagCacheManager extends Mock implements TagCacheManager {}

class MockMangaCacheManager extends Mock implements MangaCacheManager {}

class MockChapterCacheManager extends Mock implements ChapterCacheManager {}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {}

class MockSearchChapterCacheManager extends Mock
    implements SearchChapterCacheManager {}

class MockSearchMangaCacheManager extends Mock
    implements SearchMangaCacheManager {}
