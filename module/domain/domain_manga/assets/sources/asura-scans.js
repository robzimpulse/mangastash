// ==MangaStashSource==
// {
//   "id": "asura-scans",
//   "name": "Asura Scans",
//   "baseUrl": "https://asurascans.com",
//   "iconUrl": "https://asurascans.com/images/logo.webp",
//   "version": 1,
//   "contract": 1,
//   "hosts": ["asurascans.com", "cdn.asurascans.com"],
//   "timeouts": { "manga": 20000, "tags": 20000, "images": 30000 }
// }
// ==/MangaStashSource==

/**
 * Asura Scans source script (contract 1) - behavioural port of the former Dart
 * AsuraScanSourceExternal. Purpose: tells the app how to build browse/search
 * URLs and how to read the Astro-rebuilt asurascans.com pages (browse cards,
 * series detail, chapter list, reader images, genre list).
 *
 * How to use: the app evaluates this file and calls the functions of `source`
 * (`ctx` is always the LAST argument; see core_network/assets/source_ctx.js for
 * ctx.sleep / ctx.waitFor / ctx.absUrl / ctx.searchTerm). Edit selectors here
 * when the site is redesigned; prefer ids, aria-labels, data-* attributes and
 * href shapes over Tailwind classes. Tests: module/domain/domain_manga/
 * script_test (`npm ci && npm test`), fixtures in script_test/fixtures/
 * asura-scans.
 */
const source = {
  // params = SearchMangaParameter.toJson(): enums are encoded by NAME, so
  // order directions arrive as 'ascending' / 'descending' and the site wants
  // 'asc' / 'desc'. Empty title still builds the real /browse listing.
  searchUrl(params, ctx) {
    const direction = { ascending: 'asc', descending: 'desc' };
    const entries = [
      ['q', params.title ?? ''],
      ['page', params.page ?? 1],
    ];

    const first = Object.entries(params.orders ?? {})[0];
    if (first) {
      const [key, value] = first;
      const sort = { title: 'name', relevance: 'popular', rating: 'rating' }[key];
      if (sort) entries.push(['sort', sort]);
      entries.push(['order', direction[value] ?? value]);
    }
    if (params.includedTags?.length) {
      entries.push(['genres', params.includedTags.join(',')]);
    }
    if (params.status?.length) {
      entries.push(['status', params.status.join(',')]);
    }

    // Not percent-encoded on purpose: identical to the Dart url() it replaces.
    return 'https://asurascans.com/browse?' + entries.map(([k, v]) => `${k}=${v}`).join('&');
  },

  // Card anchor is the single `series-card` class; the site's card class list
  // already drifted once (rounded-lg -> rounded-md).
  search(doc, ctx) {
    const items = [...doc.querySelectorAll('div.series-card')].map((card) => {
      const heading = card.querySelector('h3');
      // Title link: the anchor wrapping the h3 when there is one, else the
      // card's first /comics/ anchor (the cover link).
      const link = heading?.closest('a') ?? card.querySelector('a[href^="/comics/"]');
      const href = link?.getAttribute('href') ?? null;
      return {
        title: heading ? heading.textContent.trim() : null,
        coverUrl: ctx.absUrl(card.querySelector('img')?.getAttribute('src') ?? null),
        webUrl: ctx.absUrl(href),
        // The status is the only capitalized meta span.
        status: card.querySelector('span.capitalize')?.textContent.trim() ?? null,
      };
    });

    // Next page exists only while its (aria-labelled) button is enabled.
    const next = doc.querySelector('button[aria-label="Next page"]');
    return { items, hasNextPage: next !== null && !next.hasAttribute('disabled') };
  },

  // Anchors are ids, headings and href shapes - not Tailwind class chains.
  manga(doc, ctx) {
    // Scope the title to the content area: a page-global h1 could be a site
    // header heading after a redesign.
    const heading =
      doc.querySelector('article h1') ?? doc.querySelector('main h1') ?? doc.querySelector('h1');
    // The webview UA is desktop: if the mobile cover id is gone or not
    // rendered, fall back to the og:image meta.
    const cover =
      doc.querySelector('img#mobile-cover-img')?.getAttribute('src') ??
      doc.querySelector('meta[property="og:image"]')?.getAttribute('content') ??
      null;

    // The Status/Type pair: a small label cell reading exactly "Status" whose
    // sibling value is the capitalized status span.
    // NOTE: `div.text-xs` + `span.capitalize` are pure styling classes and the
    // next hooks expected to drift. If status ever reads null, start here.
    let status = null;
    for (const label of doc.querySelectorAll('div.text-xs')) {
      if (label.textContent.trim() !== 'Status') continue;
      status = label.parentNode?.querySelector('span.capitalize')?.textContent.trim() ?? null;
      break;
    }

    const tags = [...doc.querySelectorAll('a[href^="/browse?genres="]')]
      .map((link) => link.textContent.trim())
      .filter((text) => text.length > 0);

    return {
      title: heading ? heading.textContent.trim() : null,
      author: doc.querySelector('a[href^="/browse?author="]')?.textContent.trim() ?? null,
      description: doc.querySelector('#description-text')?.textContent.trim() ?? null,
      status,
      coverUrl: ctx.absUrl(cover),
      tags,
    };
  },

  // The series page itself carries the full chapter list, so chaptersUrl is
  // not defined (default = the series URL).

  // Chapter rows are anchors whose href ENDS in /chapter/{slug} (the dot
  // covers decimal specials such as 10.5; the end anchor excludes reader
  // sub-pages). The page also holds same-shaped hero and related-row links, so
  // scope to the astro-island with the most such anchors and dedupe by URL.
  // There is no per-row lock marker, so rows are never filtered.
  chapters(doc, ctx) {
    const chapterHref = /\/chapter\/[\w.-]+\/?$/;
    const candidates = [...doc.querySelectorAll('a')].filter((a) =>
      chapterHref.test(a.getAttribute('href') ?? ''),
    );
    if (candidates.length === 0) return [];

    const byIsland = new Map();
    for (const candidate of candidates) {
      const island = candidate.closest('astro-island');
      if (!byIsland.has(island)) byIsland.set(island, []);
      byIsland.get(island).push(candidate);
    }
    const islandGroups = [...byIsland.entries()].filter(([island]) => island !== null);
    const rows = islandGroups.length
      ? islandGroups.map(([, group]) => group).reduce((best, g) => (g.length > best.length ? g : best))
      : byIsland.get(null);

    const seen = new Set();
    const chapters = [];
    for (const row of rows) {
      const webUrl = ctx.absUrl(row.getAttribute('href'));
      if (seen.has(webUrl)) continue;
      seen.add(webUrl);
      const title = row.querySelector('span.font-medium')?.textContent.trim() ?? null;
      chapters.push({
        title,
        chapter: title === null ? null : title.split(' ').pop(),
        readableAt: row.querySelector('.text-right')?.textContent.trim() ?? null,
        webUrl,
        scanlationGroup: 'Asura Scans',
      });
    }
    return chapters;
  },

  // Each page lives in <div data-page="n"> under the `select-none` reader and
  // the <img> carries `data-page-index` (stable, unlike Tailwind classes).
  // Lazy `src` values are populated by scrolling each image into view.
  async images(doc, ctx) {
    const query = 'div.select-none img[data-page-index]';
    // 30000 = header timeouts.images: master waited for the readiness
    // selector within the hook timeout, not the 10 s ctx default.
    await ctx.waitFor(query, 30000);
    for (const img of doc.querySelectorAll(query)) {
      img.scrollIntoView?.(); // linkedom (tests) has no scrollIntoView
      await ctx.sleep(60);
    }
    return [...doc.querySelectorAll(query)]
      .map((img) => img.getAttribute('src'))
      .filter((src) => src !== null)
      .map((src) => ctx.absUrl(src));
  },

  // Genres are listed on the browse page this source already opens, so there is
  // no dedicated tag page: null = searchUrl({page: 1}).
  tagsUrl(ctx) {
    return null;
  },

  // The genre list ships server-rendered inside the filter astro-island's
  // `props` attribute as devalue-encoded `availableGenres`
  // ([1, [[0, {name: [0, "Action"], slug: [0, "action"]}], ...]]). Plain
  // JSON.parse walks it: no dropdown click, no client-rendered DOM. A
  // truncated or reshaped payload degrades to "no tags", never a throw.
  async tags(doc, ctx) {
    // 20000 = header timeouts.tags (not the 10 s ctx default).
    await ctx.waitFor('astro-island[props*="availableGenres"]', 20000);
    let props = null;
    for (const island of doc.querySelectorAll('astro-island')) {
      const value = island.getAttribute('props');
      if (value !== null && value.includes('availableGenres')) {
        props = value;
        break;
      }
    }
    if (props === null) return [];

    let decoded;
    try {
      decoded = JSON.parse(props);
    } catch (e) {
      return [];
    }
    if (decoded === null || typeof decoded !== 'object' || Array.isArray(decoded)) return [];

    const genres = decoded.availableGenres;
    if (!Array.isArray(genres) || genres.length < 2) return [];
    const entries = genres[1];
    if (!Array.isArray(entries)) return [];

    const tags = [];
    for (const entry of entries) {
      if (!Array.isArray(entry) || entry.length < 2) continue;
      const data = entry[1];
      if (data === null || typeof data !== 'object' || Array.isArray(data)) continue;
      const name = Array.isArray(data.name) && data.name.length > 1 ? data.name[1] : null;
      const slug = Array.isArray(data.slug) && data.slug.length > 1 ? data.slug[1] : null;
      if (typeof name !== 'string') continue;
      tags.push({ id: typeof slug === 'string' ? slug : name.toLowerCase(), name });
    }
    return tags;
  },
};
