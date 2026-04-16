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

  final List regions = root.querySelectorAll(queries);
  
  return regions.map((e) {
    final Element element = e as Element;
    final link = element.querySelector('a');
    final title = link?.text ?? 'Unknown Title';
    final cover = element.querySelector('img')?.attributes['src'];
    
    return MangaScrapped(
      title: title,
      coverUrl: cover,
      webUrl: link?.attributes['href'],
    );
  }).toList().cast<MangaScrapped>();
}

bool haveNextSearchPage(Document root) {
  return root.querySelector('button[aria-label="Next page"]') != null;
}
