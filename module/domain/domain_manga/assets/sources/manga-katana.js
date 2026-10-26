// ==MangaStashSource==
// {
//   "id": "manga-katana",
//   "name": "Manga Katana",
//   "baseUrl": "https://mangakatana.com",
//   "iconUrl": "https://mangakatana.com/favicon.ico",
//   "version": 1,
//   "contract": 1,
//   "hosts": ["mangakatana.com", "mkcdn.mangakatana.com"],
//   "timeouts": { "images": 30000 }
// }
// ==/MangaStashSource==

/**
 * Manga Katana source script (contract 1) - behavioural port of the former Dart
 * MangakatanaSourceExternal. Purpose: tells the app how to build browse/search
 * URLs and how to read mangakatana.com's server-rendered pages (card lists,
 * series detail with its chapter table, reader images, genre links).
 *
 * How to use: the app evaluates this file and calls the functions of `source`
 * (`ctx` is always the LAST argument; see core_network/assets/source_ctx.js for
 * ctx.sleep / ctx.waitFor / ctx.absUrl / ctx.searchTerm). Edit selectors here
 * when the site is redesigned; prefer row classes and href shapes over layout.
 * Tests: module/domain/domain_manga/script_test (`npm ci && npm test`),
 * fixtures in script_test/fixtures/manga-katana.
 *
 * Deliberate difference from the Dart source: search cards carry NO `tags`.
 * `div.item[data-genre]` holds numeric genre ids (",14,15,2,"), not names, and
 * the page has no id -> name map; ids must never be stored as tag names.
 * Detail-page tags (genre link text) are unchanged.
 */
const source = {
  // params = SearchMangaParameter.toJson(); absent fields arrive as null.
  // Browse (empty title) must hit a real listing: the root search route renders
  // "Not found any results" and the site's small-viewport JS empties the Hot
  // Manga widget, leaving zero cards - page 1 is the homepage, then /page/N.
  // A query uses the root route with search_by=m_name (`/search` is a 404); it
  // is paginated as /page/N?search=... (#165).
  searchUrl(params, ctx) {
    // Same output as Dart's Uri.encodeQueryComponent: everything except
    // A-Z a-z 0-9 - . _ ~ is percent-encoded, a space becomes '+'.
    const q = encodeURIComponent(params.title ?? '')
      .replace(/[!'()*]/g, (c) => '%' + c.charCodeAt(0).toString(16).toUpperCase())
      .replace(/%20/g, '+');
    const page = params.page ?? 1;
    if (q === '') {
      return page <= 1 ? 'https://mangakatana.com/' : `https://mangakatana.com/page/${page}`;
    }
    return page <= 1
      ? `https://mangakatana.com/?search=${q}&search_by=m_name`
      : `https://mangakatana.com/page/${page}?search=${q}&search_by=m_name`;
  },

  // Both card templates (`.d-cell` and `.media`) share the shape
  // div.item[data-id] -> h3.title a + img + optional div.status.ongoing. Scope
  // to #book_list: on the homepage the #hot_book sidebar repeats its own
  // .item cards on every page. data-genre is deliberately ignored (see header).
  search(doc, ctx) {
    const items = [];
    for (const item of doc.querySelectorAll('#book_list div.item[data-id]')) {
      const link = item.querySelector('h3.title a');
      if (link === null) continue;
      const img = item.querySelector('img');
      items.push({
        title: link.textContent.trim(),
        coverUrl: ctx.absUrl(img?.getAttribute('data-src') ?? img?.getAttribute('src') ?? null),
        webUrl: ctx.absUrl(link.getAttribute('href')),
        status: item.querySelector('div.status.ongoing')?.textContent.trim() ?? null,
      });
    }
    // Browse and search both render a ul.uk-pagination whose final entry is an
    // <a class="next ..."> link; the last page has none.
    return { items, hasNextPage: doc.querySelector('ul.uk-pagination a.next') !== null };
  },

  // Info rows are li.d-row / li.d-row-small (the class changed in 2026-10 -
  // match both); genre links carry ABSOLUTE hrefs and are scoped to the rows so
  // the navbar's genre dropdown (plain <li>) never leaks in (#164).
  manga(doc, ctx) {
    const rowValue = (label) => {
      for (const row of doc.querySelectorAll('li.d-row, li.d-row-small')) {
        const rowLabel = row.querySelector('div.d-cell-small.label')?.textContent.trim();
        if (rowLabel === undefined || !rowLabel.includes(label)) continue;
        return row.querySelector('div.d-cell-small.value')?.textContent.trim() ?? null;
      }
      return null;
    };
    const cover = doc.querySelector('div.wrap_img img');

    return {
      title: doc.querySelector('h1')?.textContent.trim() ?? null,
      author: rowValue('Author(s)'),
      description: doc.querySelector('div.summary p')?.textContent.trim() ?? null,
      status: rowValue('Status'),
      tags: [
        ...doc.querySelectorAll('li.d-row a[href*="/genre/"], li.d-row-small a[href*="/genre/"]'),
      ]
        .map((a) => a.textContent.trim())
        .filter((text) => text !== ''),
      coverUrl: ctx.absUrl(cover?.getAttribute('data-src') ?? cover?.getAttribute('src') ?? null),
    };
  },

  // No chaptersUrl: the series page itself carries the full chapter list.
  chapters(doc, ctx) {
    const chapters = [];
    for (const row of doc.querySelectorAll('table tr')) {
      const link = row.querySelector('td div.chapter a');
      if (link === null) continue;
      const title = link.textContent.trim();
      const updateTime = row.querySelector('td div.update_time')?.textContent.trim() ?? null;
      const words = title.split(' ');
      chapters.push({
        title,
        // First numeric run ("1040" from "Chapter 1040"), else the last word.
        chapter: title.match(/\d+(\.\d+)?/)?.[0] ?? words[words.length - 1],
        webUrl: ctx.absUrl(link.getAttribute('href')),
        readableAt: updateTime,
        publishAt: updateTime,
      });
    }
    return chapters;
  },

  // The reader <img>s only carry data-src="#" placeholders; the real URLs live
  // in the page's inline `var thzq = [...]` array. Copy each into the matching
  // placeholder, then drop any that remain "#".
  async images(doc, ctx) {
    const query = '#imgs .wrap_img img';
    // Header timeouts.images is 30000.
    // Stay 3000 ms below the header timeout so a stale selector fails with the
    // clean `waitFor timed out: <selector>` error + page HTML instead of the
    // runner's generic timeout (which captures no HTML).
    await ctx.waitFor(query, 27000);
    if (typeof thzq !== 'undefined') {
      doc.querySelectorAll(query).forEach((img, i) => {
        if (thzq[i]) img.setAttribute('data-src', thzq[i]);
      });
    }
    return [...doc.querySelectorAll(query)]
      .map((img) => img.getAttribute('data-src'))
      .filter((src) => src !== null && src !== '#')
      .map((src) => ctx.absUrl(src));
  },

  // Genres are listed on the page searchUrl already opens (nav dropdown on the
  // homepage), so there is no dedicated tag page: null = searchUrl({page: 1}).
  tagsUrl(ctx) {
    return null;
  },

  // Genres appear as <a href=".../genre/{slug}"> links; any such link is a
  // valid tag. Deduped by name (the last slug seen wins).
  tags(doc, ctx) {
    const byName = new Map();
    for (const link of doc.querySelectorAll('a[href*="/genre/"]')) {
      const name = link.textContent.trim();
      if (name === '') continue;
      const slugs = (link.getAttribute('href') ?? '').split('/').filter((s) => s !== '');
      byName.set(name, slugs[slugs.length - 1] ?? name.toLowerCase());
    }
    return [...byName].map(([name, id]) => ({ id, name }));
  },
};
