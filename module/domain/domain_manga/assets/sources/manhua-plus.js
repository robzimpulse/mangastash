// ==MangaStashSource==
// {
//   "id": "manhua-plus",
//   "name": "Manhua Plus",
//   "baseUrl": "https://manhuaplus.com",
//   "iconUrl": "https://manhuaplus.com/wp-content/uploads/2020/07/cropped-manhua-vuong-den-1-192x192.jpg",
//   "version": 1,
//   "contract": 1,
//   "hosts": ["manhuaplus.com", "cdn.mhpcdn.com"],
//   "timeouts": { "images": 30000 }
// }
// ==/MangaStashSource==

/**
 * Manhua Plus source script (contract 1) - behavioural port of the former Dart
 * ManhuaPlusSourceExternal. Purpose: tells the app how to build browse/search
 * URLs and how to read manhuaplus.com's pages. The site runs the Madara
 * WordPress theme and is fully server-rendered, so every page function parses
 * the DOM directly; only the reader needs one step (copy lazyload `data-src`
 * into `src`), which `images` now does itself instead of an injected script.
 *
 * How to use: the app evaluates this file and calls the functions of `source`
 * (`ctx` is always the LAST argument; see core_network/assets/source_ctx.js for
 * ctx.sleep / ctx.waitFor / ctx.absUrl / ctx.searchTerm). Edit selectors here
 * when the site is redesigned; prefer row classes and href shapes over layout.
 * Tests: module/domain/domain_manga/script_test (`npm ci && npm test`),
 * fixtures in script_test/fixtures/manhua-plus.
 *
 * Differences from the Dart source (all deliberate):
 *  - No waitFor anywhere: Dart declared no readyWhenSelectors, so `images`
 *    returns [] on a page without reader images (it does NOT throw). The 30 s
 *    budget lives in the header `timeouts.images`, matching Dart's reader
 *    timeout.
 *  - URLs are resolved with ctx.absUrl (WHATWG URL against baseUrl) rather than
 *    Dart's startsWith('http') / '//' / '/' prefix rules; same result for all
 *    shapes the site emits, and it also trims the stray whitespace Madara puts
 *    around lazyload `data-src` values. Cover URLs are absolutized too (Dart
 *    returned them raw).
 *  - Reader `<img>`s whose src is blank are dropped (Dart kept empty strings).
 *  - Chapter rows without an <a> are skipped (Dart emitted an all-null row).
 */
const source = {
  // params = SearchMangaParameter.toJson(); absent fields arrive as null.
  // Browse (empty title) must hit the homepage: `?s=` renders WordPress's "You
  // searched for" page with zero cards, while the homepage (and /page/N/) lists
  // manga in div.page-item-detail / div.slider__item cards.
  searchUrl(params, ctx) {
    // Same output as Dart's Uri.encodeQueryComponent: everything except
    // A-Z a-z 0-9 - . _ ~ is percent-encoded, a space becomes '+'.
    const q = encodeURIComponent(params.title ?? '')
      .replace(/[!'()*]/g, (c) => '%' + c.charCodeAt(0).toString(16).toUpperCase())
      .replace(/%20/g, '+');
    const page = params.page ?? 1;
    if (q === '') {
      return page > 1 ? `https://manhuaplus.com/page/${page}/` : 'https://manhuaplus.com/';
    }
    return page > 1
      ? `https://manhuaplus.com/page/${page}/?s=${q}`
      : `https://manhuaplus.com/?s=${q}`;
  },

  // Two card templates, deduped by raw href (first wins): slider cards
  // (div.slider__item > div.item__wrap) and archive cards (div.page-item-detail,
  // which has no `.manga` class on this theme).
  search(doc, ctx) {
    const items = [];
    const seen = new Set();

    for (const item of doc.querySelectorAll('div.slider__item div.item__wrap')) {
      const link =
        item.querySelector('div.post-title h4 a') ?? item.querySelector('a[href*="/manga/"]');
      if (link === null) continue;
      const href = link.getAttribute('href');
      if (href === null || seen.has(href)) continue;
      seen.add(href);
      const cover = item.querySelector('div.slider__thumb img');
      items.push({
        title: link.textContent.trim(),
        coverUrl: ctx.absUrl(cover?.getAttribute('data-src') ?? cover?.getAttribute('src') ?? null),
        webUrl: ctx.absUrl(href),
      });
    }

    for (const item of doc.querySelectorAll('div.page-item-detail')) {
      const link =
        item.querySelector('div.item-summary div.post-title h4 a') ??
        item.querySelector('div.item-thumb a[title]');
      if (link === null) continue;
      const href = link.getAttribute('href');
      if (href === null || seen.has(href)) continue;
      seen.add(href);
      const cover = item.querySelector('div.item-thumb img');
      items.push({
        title: (link.getAttribute('title') ?? link.textContent).trim(),
        coverUrl: ctx.absUrl(cover?.getAttribute('data-src') ?? cover?.getAttribute('src') ?? null),
        webUrl: ctx.absUrl(href),
      });
    }

    // Madara pagination: a wp-pagenavi `.next` link, or `a.next.page-numbers`.
    const hasNextPage =
      doc.querySelector('a.next.page-numbers') !== null ||
      doc.querySelector('.wp-pagenavi .next') !== null;
    return { items, hasNextPage };
  },

  // Title comes from the h1 with Madara badge spans ("New", "Hot") removed;
  // info rows are div.post-content_item blocks keyed by their heading label.
  manga(doc, ctx) {
    const rowValue = (label) => {
      for (const row of doc.querySelectorAll('div.post-content_item')) {
        const heading = row.querySelector('.summary-heading, h5')?.textContent.trim();
        if (heading === undefined || !heading.includes(label)) continue;
        const values = row.querySelectorAll('.summary-content');
        return values.length === 0 ? null : values[values.length - 1].textContent.trim();
      }
      return null;
    };
    const h1 = doc.querySelector('h1');
    let title = null;
    if (h1 !== null) {
      const clone = h1.cloneNode(true);
      clone.querySelectorAll('.manga-title-badges').forEach((badge) => badge.remove());
      title = clone.textContent.trim();
    }
    const cover = doc.querySelector('div.tab-summary img');

    return {
      title,
      author: doc.querySelector('div.author-content a')?.textContent.trim() ?? null,
      description:
        doc.querySelector('div.description-summary')?.textContent.trim() ??
        doc.querySelector('div.summary__content p')?.textContent.trim() ??
        null,
      status: rowValue('Status'),
      tags: [...doc.querySelectorAll('div.genres-content a')]
        .map((a) => a.textContent.trim())
        .filter((text) => text !== ''),
      coverUrl: ctx.absUrl(cover?.getAttribute('data-src') ?? cover?.getAttribute('src') ?? null),
    };
  },

  // No chaptersUrl: the series page itself carries the full chapter list.
  chapters(doc, ctx) {
    const chapters = [];
    for (const row of doc.querySelectorAll('li.wp-manga-chapter')) {
      const link = row.querySelector('a');
      if (link === null) continue;
      const title = link.textContent.trim();
      const date = row.querySelector('span.chapter-release-date i')?.textContent.trim() ?? null;
      const words = title.split(' ');
      chapters.push({
        title,
        // First numeric run ("1100" from "Chapter 1100"), else the last word.
        chapter: title.match(/\d+(\.\d+)?/)?.[0] ?? words[words.length - 1],
        webUrl: ctx.absUrl(link.getAttribute('href')),
        readableAt: date,
        publishAt: date,
      });
    }
    return chapters;
  },

  // Reader <img>s lazy-load: the real URL sits in `data-src` with an empty or
  // placeholder `src`. Copy data-src into src (what the old injected script
  // did), then read src.
  async images(doc, ctx) {
    const query = 'div.reading-content img';
    doc.querySelectorAll(`${query}[data-src]`).forEach((img) => {
      img.setAttribute('src', img.getAttribute('data-src'));
    });
    return [...doc.querySelectorAll(query)]
      .map((img) => (img.getAttribute('src') ?? '').trim())
      .filter((src) => src !== '')
      .map((src) => ctx.absUrl(src));
  },

  // Genres are listed on the page searchUrl already opens, so there is no
  // dedicated tag page: null = searchUrl({page: 1}).
  tagsUrl(ctx) {
    return null;
  },

  // Genres appear as <a href=".../manga-genre/{slug}/"> links; any such link is
  // a valid tag. Deduped by name (the last slug seen wins).
  tags(doc, ctx) {
    const byName = new Map();
    for (const link of doc.querySelectorAll('a[href*="/manga-genre/"]')) {
      const name = link.textContent.trim();
      if (name === '') continue;
      const slugs = (link.getAttribute('href') ?? '').split('/').filter((s) => s !== '');
      byName.set(name, slugs[slugs.length - 1] ?? name.toLowerCase());
    }
    return [...byName].map(([name, id]) => ({ id, name }));
  },
};
