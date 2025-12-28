import 'package:core_storage/core_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockImagesCacheManager extends Mock implements ImagesCacheManager {
  MockImagesCacheManager() {
    when(() => deleteFileEvent).thenAnswer((_) => Stream.empty());
  }
}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {
  MockConverterCacheManager() {
    when(() => deleteFileEvent).thenAnswer((_) => Stream.empty());
  }
}

class MockTagCacheManager extends Mock implements TagCacheManager {
  MockTagCacheManager() {
    when(() => deleteFileEvent).thenAnswer((_) => Stream.empty());
  }
}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {
  MockHtmlCacheManager() {
    when(() => deleteFileEvent).thenAnswer((_) => Stream.empty());
  }
}

class MockSearchChapterCacheManager extends Mock
    implements SearchChapterCacheManager {
  MockSearchChapterCacheManager() {
    when(() => deleteFileEvent).thenAnswer((_) => Stream.empty());
  }
}

class MockSearchMangaCacheManager extends Mock
    implements SearchMangaCacheManager {
  MockSearchMangaCacheManager() {
    when(() => deleteFileEvent).thenAnswer((_) => Stream.empty());
  }
}
