import 'package:core_storage/core_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockImageCacheManager extends Mock implements ImageCacheManager {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockMangaCacheManager extends Mock implements MangaCacheManager {}

class MockChapterCacheManager extends Mock implements ChapterCacheManager {}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {}

class MockSearchChapterCacheManager extends Mock
    implements SearchChapterCacheManager {}

class MockSearchMangaCacheManager extends Mock
    implements SearchMangaCacheManager {}
