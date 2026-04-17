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
  return [];
}

String getSearchUrl(dynamic params) {
  return 'https://asurascans.com/browse?q=test&page=1';
}

List<MangaScrapped> parseSearch(Document root) {
  final regions = root.querySelectorAll('div.series-card');

  final List<MangaScrapped> result = [];

  for (var i = 0, len = regions.length; i < len; i++) {
    final e = regions[i] as Element;
    // Asura Scans card structure fix for test runner HTML
    final link = e.querySelector('a');
    
    String? title;
    String? webUrl;
    if (link != null) {
      title = link.text.trim();
      final href = link.attributes['href'];
      if (href != null) {
        if (href.startsWith('http')) {
          webUrl = href;
        } else {
          webUrl = 'https://asurascans.com' + href;
        }
      }
    }

    String? coverUrl;
    final img = e.querySelector('img');
    if (img != null) {
      coverUrl = img.attributes['src'];
    }

    String? status;
    final statusElement = e.querySelector('span.text-xs.font-medium.px-2.py-1.rounded.capitalize');
    if (statusElement != null) {
      status = statusElement.text.trim();
    }

    result.add(MangaScrapped(
      title: title,
      coverUrl: coverUrl,
      webUrl: webUrl,
      status: status,
    ));
  }

  return result;
}

bool haveNextSearchPage(Document root) {
  final queries = 'nav.flex.items-center.justify-center.mt-8.pb-8';

  final region = root.querySelector(queries);
  if (region == null) return false;

  final buttons = region.querySelectorAll('button');
  for (var i = 0, len = buttons.length; i < len; i++) {
    final b = buttons[i] as Element;
    if (b.attributes['aria-label'] == 'Next page') {
      final disabled = b.attributes['disabled'];
      return disabled == null;
    }
  }

  return false;
}

List<String> getMangaScripts() {
  return [
    "window.document.querySelectorAll('div.flex.z-10.relative.mt-2.justify-end')[0].querySelector('button').click()"
  ];
}

MangaScrapped parseManga(Document root) {
  final region = root.querySelector('div.px-4.py-5');

  String? coverUrl;
  String? title;
  if (region != null) {
    final area = region.querySelector('div.flex.gap-3.mb-4');
    if (area != null) {
      final img = area.querySelector('img');
      if (img != null) {
        coverUrl = img.attributes['src'];
      }
      final titleElement = area.querySelector('h2.font-bold.text-base.line-clamp-2');
      if (titleElement != null) {
        title = titleElement.text.trim();
      }
    }
  }

  String? description;
  if (region != null) {
    final descElement = region.querySelector('div.text-xs.leading-relaxed.prose.prose-invert.max-w-full');
    if (descElement != null) {
      description = descElement.text.trim();
    }
  }

  String? author;
  if (region != null) {
    final attributes = region.querySelectorAll('div.flex.items-center.justify-between.rounded.px-4');
    for (var i = 0; i < attributes.length; i++) {
      final e = attributes[i] as Element;
      final keyElement = e.querySelector('div.flex.items-center.gap-2');
      if (keyElement != null) {
        final key = keyElement.text.trim();
        if (key == 'Author') {
          final valElement = e.querySelector('span.text-sm.font-medium');
          if (valElement != null) {
            author = valElement.text.trim();
          }
        }
      }
    }
  }

  final List<String> tags = [];
  if (region != null) {
    final genres = region.querySelector('div.flex.flex-wrap.gap-2.text-xs.mt-4');
    if (genres != null) {
      final children = genres.children;
      for (var i = 0; i < children.length; i++) {
        final e = children[i] as Element;
        tags.add(e.text.trim());
      }
    }
  }

  return MangaScrapped(
    title: title,
    author: author,
    description: description,
    coverUrl: coverUrl,
    tags: tags,
  );
}

List<String> getChapterImageScripts() {
  final query = 'div.min-h-screen.bg-black > div.select-none > div.max-w-full.mx-auto.overflow-hidden.flex.flex-col > div.relative.w-full';
  return [
    'var elements = document.querySelectorAll(\'$query\');',
    'for (let i = 0; i < elements.length; i++) { setTimeout(() => elements[i].scrollIntoView(), 500 * i); }',
  ];
}

List<String> parseChapterImages(Document root) {
  final query = 'div.min-h-screen.bg-black > div.select-none > div.max-w-full.mx-auto.overflow-hidden.flex.flex-col > div.relative.w-full > img.w-full.block.relative.z-10';
  final regions = root.querySelectorAll(query);
  final List<String> images = [];
  for (var i = 0, len = regions.length; i < len; i++) {
    final e = regions[i] as Element;
    final src = e.attributes['src'];
    if (src != null) images.add(src);
  }
  return images;
}

List<ChapterScrapped> parseChapters(Document root) {
  final regions = root.querySelectorAll('a.group.flex.items-center.justify-between.px-4.py-4.transition-colors');
  final List<ChapterScrapped> chapters = [];

  for (var i = 0, len = regions.length; i < len; i++) {
    final e = regions[i] as Element;
    final classAttr = e.attributes['class'];
    final isLocked = classAttr != null && classAttr.contains('bg-gradient-to-r from-amber-500/5 to-transparent');
    
    if (!isLocked) {
      final titleContainer = e.querySelector('div.flex.items-center.gap-3.min-w-0.flex-1');
      final titleInner = titleContainer?.querySelector('div.min-w-0.flex-1');
      final titleElement = titleInner?.querySelector('div.flex.items-center.gap-2');
      
      final dateElement = e.querySelector('div.flex-shrink-0.ml-3.text-right');

      final title = titleElement?.text.trim();
      String? chapter;
      if (title != null) {
        final parts = title.split(' ');
        if (parts.isNotEmpty) {
          chapter = parts[parts.length - 1];
        }
      }

      String? href = e.attributes['href'];
      String? webUrl;
      if (href != null) {
        webUrl = 'https://asurascans.com' + href;
      }

      chapters.add(ChapterScrapped(
        title: title,
        chapter: chapter,
        readableAt: dateElement?.text.trim(),
        webUrl: webUrl,
        scanlationGroup: 'Asura Scans',
      ));
    }
  }

  return chapters;
}
