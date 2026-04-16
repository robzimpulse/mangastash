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
      print('   - ${manga.title} (URL: ${manga.webUrl})');
    }

    final hasNext = await dynamicSource.searchMangaUseCase.haveNextPage(root: document);
    print('\n4. Testing Pagination...');
    print('   Has Next Page: $hasNext');

    print('\n--- PoC Test Completed Successfully ---');
  } catch (e, stack) {
    print('\n--- PoC Test FAILED ---');
    print('Error: $e');
    print('Stack: $stack');
  }
}
