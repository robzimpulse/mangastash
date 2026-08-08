import 'package:domain_manga/src/sources/asura_scan_source_external.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

/// Reader fixture trimmed to the nodes the parser reads. Mirrors the current
/// asurascans.com chapter reader (Astro rebuild): images live inside
/// <div data-page="n" class="w-full"> as <img class="w-full block">. The old
/// `div.relative.w-full > img.w-full.block.relative.z-10` chain matched
/// nothing on this markup, so all images were dropped.
const _readerHtml = '''
<html><body>
<div class="min-h-screen bg-black">
  <div class="select-none">
    <div class="max-w-full md:max-w-[720px] mx-auto overflow-hidden flex flex-col leading-[0]">
      <div data-page="0" class="w-full" style="aspect-ratio:1200 / 800">
        <img src="https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/001.webp?v=1770499638"
             alt="Page 1 - Chapter 1 - Ending Maker" data-page-index="0" class="w-full block" decoding="async"/>
      </div>
      <div data-page="1" class="w-full" style="aspect-ratio:1200 / 800">
        <img src="https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/002.webp?v=1770499638"
             alt="Page 2 - Chapter 1 - Ending Maker" data-page-index="1" class="w-full block" decoding="async"/>
      </div>
      <div data-page="2" class="w-full" style="aspect-ratio:1200 / 800">
        <img src="https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/003.webp?v=1770499638"
             alt="Page 3 - Chapter 1 - Ending Maker" data-page-index="2" class="w-full block" decoding="async"/>
      </div>
    </div>
  </div>
</div>
</body></html>
''';

void main() {
  final source = AsuraScanSourceExternal();

  test('identity and registration shape', () {
    expect(source.name, 'Asura Scans');
    expect(source.baseUrl, 'https://asurascans.com');
    expect(source.builtIn, isFalse);
    expect(source.getChapterImageUseCase, isA<GetChapterImageSourceExternalUseCase>());
  });

  test('reader parses all page images in order', () async {
    final images = await source.getChapterImageUseCase
        .parse(root: html_parser.parse(_readerHtml));
    expect(images, hasLength(3));
    expect(
      images,
      [
        'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/001.webp?v=1770499638',
        'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/002.webp?v=1770499638',
        'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/003.webp?v=1770499638',
      ],
    );
  });

  test('reader scripts target the current reader container', () {
    final scripts = source.getChapterImageUseCase.scripts;
    expect(scripts, isNotEmpty);
    expect(scripts.join(), contains('select-none'));
  });
}
