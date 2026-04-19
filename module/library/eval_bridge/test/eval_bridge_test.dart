import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:eval_bridge/eval_bridge.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

void main() {
  group('EvalBridge PoC Test', () {
    const sourceCode = '''
import 'package:html/dom.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

class MangaProvider {
  static Map<String, dynamic> get metadata => {
    'id': 'asura_dynamic_poc',
    'name': 'Asura Scans (Dynamic PoC)',
    'version': '1.0.0',
    'minAppVersion': '0.1.0',
    'baseUrl': 'https://asurascans.com',
    'iconUrl': 'https://asurascans.com/images/logo.webp',
  };
}

List<String> getSearchScripts() {
  return [
    "console.log('Running dynamic search script');",
  ];
}

String getSearchUrl(Map<String, dynamic> params) {
  final title = params['title'];
  final page = params['page'];
  return 'https://asurascans.com/browse?q=\$title&page=\$page';
}

List<MangaScrapped> parseSearch(Document root) {
  final queries = 'div.series-card';

  final regions = root.querySelectorAll(queries);
  
  return regions.map((e) {
    final link = e.querySelector('a');
    final title = link?.text ?? 'Unknown Title';
    final cover = e.querySelector('img')?.attributes['src'];
    
    return MangaScrapped(
      title: title,
      coverUrl: cover,
      webUrl: link?.attributes['href'],
    );
  }).toList();
}

bool haveNextSearchPage(Document root) {
  return root.querySelector('button[aria-label="Next page"]') != null;
}
''';

    test('should load metadata and parse HTML', () async {
      final dynamicSource = EvalBridge.loadSource(sourceCode);
      
      expect(dynamicSource.name, 'Asura Scans (Dynamic PoC)');
      expect(dynamicSource.baseUrl, 'https://asurascans.com');

      final url = dynamicSource.searchMangaUseCase.url(
        parameter: SearchMangaParameter(title: 'Solo Leveling', page: 1),
      );
      expect(url, contains('q=Solo Leveling'));

      final html = '''
        <html>
          <body>
            <div class="series-card">
              <a href="/solo-leveling">Solo Leveling</a>
              <img src="/solo.jpg">
            </div>
            <button aria-label="Next page">Next</button>
          </body>
        </html>
      ''';
      
      final document = Document.html(html);
      final results = await dynamicSource.searchMangaUseCase.parse(root: document);
      
      expect(results.length, 1);
      expect(results.first.title, 'Solo Leveling');
      
      final hasNext = await dynamicSource.searchMangaUseCase.haveNextPage(root: document);
      expect(hasNext, isTrue);
    });
  });
}
