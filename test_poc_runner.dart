import 'dart:io';

import 'package:eval_bridge/eval_bridge.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

void main() async {
  print('--- Starting PoC Test ---');
  
  final sourceCode = File('poc_dynamic_asura.dart').readAsStringSync();
  
  try {
    print('1. Compiling and Loading Dynamic Source...');
    final dynamicSource = EvalBridge.loadSource(sourceCode);
    print('   SUCCESS: Loaded source: \${dynamicSource.name}');
    print('   Metadata BaseURL: \${dynamicSource.baseUrl}');

    print('\n2. Testing URL Generation...');
    final url = dynamicSource.searchMangaUseCase.url(
      parameter: SearchMangaParameter(title: 'Solo Leveling', page: 1),
    );
    print('   Generated URL: \$url');

    print('\n3. Testing HTML Parsing...');
    final html = '''
      <html>
        <body>
          <div class="series-card">
            <a href="https://asurascans.com/solo-leveling">Solo Leveling</a>
            <img src="https://asurascans.com/solo.jpg">
          </div>
          <div class="series-card">
            <a href="https://asurascans.com/omniscient-reader">Omniscient Reader</a>
            <img src="https://asurascans.com/orv.jpg">
          </div>
          <button aria-label="Next page">Next</button>
        </body>
      </html>
    ''';
    
    final document = Document.html(html);
    final results = await dynamicSource.searchMangaUseCase.parse(root: document);
    
    print('   Scrapped ${results.length} mangas:');
    for (var manga in results) {
      print('   - ${manga.title} (URL: ${manga.webUrl}, Status: ${manga.status})');
    }

    final hasNext = await dynamicSource.searchMangaUseCase.haveNextPage(root: document);
    print('\n4. Testing Pagination...');
    print('   Has Next Page: $hasNext');

    print('\n5. Testing Manga Detail Parsing...');
    final detailHtml = '''
      <div class="px-4 py-5">
        <div class="flex gap-3 mb-4">
          <img src="https://asurascans.com/cover.jpg">
          <h2 class="font-bold text-base line-clamp-2">Solo Leveling</h2>
        </div>
        <div class="flex items-center justify-between rounded px-4">
          <div class="flex items-center gap-2">Author</div>
          <span class="text-sm font-medium">Chugong</span>
        </div>
        <div class="text-xs leading-relaxed prose prose-invert max-w-full">
          The world's weakest hunter...
        </div>
        <div class="flex flex-wrap gap-2 text-xs mt-4">
          <span>Action</span>
          <span>Adventure</span>
        </div>
      </div>
    ''';
    final detailDoc = Document.html(detailHtml);
    final mangaDetail = await dynamicSource.getMangaUseCase.parse(root: detailDoc);
    print('   Title: ${mangaDetail.title}');
    print('   Author: ${mangaDetail.author}');
    // print('   Tags: ${mangaDetail.tags}');

    print('\n6. Testing Chapter List Parsing...');
    final chapterHtml = '''
      <a class="group flex items-center justify-between px-4 py-4 transition-colors" href="/chapters/1">
        <div class="flex items-center gap-3 min-w-0 flex-1">
          <div class="min-w-0 flex-1">
            <div class="flex items-center gap-2">Solo Leveling Chapter 1</div>
          </div>
        </div>
        <div class="flex-shrink-0 ml-3 text-right">2 days ago</div>
      </a>
    ''';
    final chapterDoc = Document.html(chapterHtml);
    final chapters = await dynamicSource.listChapterUseCase.parse(root: chapterDoc);
    print('   Found ${chapters.length} chapters');
    if (chapters.isNotEmpty) {
      print('   First chapter: ${chapters[0].title} (No: ${chapters[0].chapter}, URL: ${chapters[0].webUrl})');
    }

    print('\n--- PoC Test Completed Successfully ---');
  } catch (e, stack) {
    print('\n--- PoC Test FAILED ---');
    print('Error: $e');
    print('Stack: $stack');
  }
}
