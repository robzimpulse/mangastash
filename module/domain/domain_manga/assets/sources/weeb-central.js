// ==MangaStashSource==
// {
//   "id": "weeb-central",
//   "name": "Weeb Central",
//   "baseUrl": "https://weebcentral.com",
//   "iconUrl": "https://weebcentral.com/favicon.ico",
//   "version": 1,
//   "contract": 1,
//   "hosts": ["weebcentral.com", "temp.compsci88.com"],
//   "timeouts": { "images": 30000 }
// }
// ==/MangaStashSource==

/**
 * Weeb Central source script (contract 1) - behavioural port of the former Dart
 * WeebCentralSourceExternal. Purpose: tells the app how to build the htmx
 * search-fragment URL and how to read weebcentral.com's server-rendered pages
 * (search cards, series detail, full chapter list, reader images, genre list).
 *
 * How to use: the app evaluates this file and calls the functions of `source`
 * (`ctx` is always the LAST argument; see core_network/assets/source_ctx.js for
 * ctx.sleep / ctx.waitFor / ctx.absUrl / ctx.searchTerm). Edit selectors here
 * when the site is redesigned; prefer structure (article/section/strong
 * labels, href shapes) over Tailwind classes. Tests: module/domain/domain_manga/
 * script_test (`npm ci && npm test`), fixtures in script_test/fixtures/
 * weeb-central.
 */
const source = {
  // params = SearchMangaParameter.toJson(): enums are encoded by NAME (orders
  // {rating: 'descending'}, status ['ongoing']) and absent fields arrive as
  // null. Targets the /search/data htmx fragment, whose batch the server clamps
  // to 32 (it ignores `limit`), so the page size is hardcoded for offsets.
  searchUrl(params, ctx) {
    const pageSize = 32;
    const sorts = {
      title: 'Alphabet',
      relevance: 'Best Match',
      followedCount: 'Subscribers',
      createdAt: 'Recently Added',
      latestUploadedChapter: 'Latest Updates',
      rating: 'Popularity',
    };
    const statuses = {
      ongoing: 'Ongoing',
      completed: 'Complete',
      hiatus: 'Hiatus',
      cancelled: 'Canceled',
    };

    const first = Object.entries(params.orders ?? {})[0];
    const sort = first ? sorts[first[0]] : undefined;
    const direction = first ? (first[1] === 'ascending' ? 'Ascending' : 'Descending') : undefined;
    const status = statuses[(params.status ?? [])[0]];

    const entries = [
      ['text', params.title ?? ''],
      ['limit', pageSize],
      ['offset', ((params.page ?? 1) - 1) * pageSize],
      ['display_mode', 'Full Display'],
    ];
    if (sort !== undefined) entries.push(['sort', sort]);
    if (direction !== undefined) entries.push(['order', direction]);
    if (status !== undefined) entries.push(['included_status', status]);
    for (const tag of params.includedTags ?? []) entries.push(['included_tag', tag]);

    // Same output as Dart's Uri.encodeQueryComponent: everything except
    // A-Z a-z 0-9 - . _ ~ is percent-encoded, a space becomes '+'.
    const encode = (value) =>
      encodeURIComponent(String(value))
        .replace(/[!'()*]/g, (c) => '%' + c.charCodeAt(0).toString(16).toUpperCase())
        .replace(/%20/g, '+');

    return (
      'https://weebcentral.com/search/data?' +
      entries.map(([k, v]) => `${k}=${encode(v)}`).join('&')
    );
  },

  // A card is a structural <article>: not nested in another article, holding
  // BOTH a series link and an image; cards are deduped by webUrl. Metadata is
  // the section carrying LABELED rows (strongs with a colon: "Status:",
  // "Author(s):", "Tag(s):") - the cover section's anchor can carry text too
  // (ribbon + overlay title, #162), and badges like <strong>New</strong> lack
  // the colon (#169).
  search(doc, ctx) {
    const items = [];
    const seen = new Set();
    const articles = [...doc.querySelectorAll('article')].filter(
      (article) =>
        !article.parentElement?.closest('article') &&
        article.querySelector('a[href*="/series/"]') !== null &&
        article.querySelector('img') !== null,
    );

    for (const article of articles) {
      const hasTextLink = (section) =>
        [...section.querySelectorAll('a[href*="/series/"]')].some(
          (a) => a.textContent.trim() !== '',
        );
      const textLinkSections = [...article.querySelectorAll('section')].filter(hasTextLink);
      const labeled = textLinkSections.find((section) =>
        [...section.querySelectorAll('strong')].some((s) => s.textContent.includes(':')),
      );
      // No labeled section: degrade to the last text-link section WITHOUT a
      // cover image (order-proof), else plain last.
      const metadata =
        labeled ??
        textLinkSections.filter((section) => section.querySelector('img') === null).at(-1) ??
        textLinkSections.at(-1);

      const link = metadata
        ? [...metadata.querySelectorAll('a[href*="/series/"]')].find(
            (a) => a.textContent.trim() !== '',
          )
        : undefined;

      // No title link -> not a card (image-only recommendation rows). Also
      // dedupes repeated webUrls.
      const href = link?.getAttribute('href') ?? null;
      if (href === null || seen.has(href)) continue;
      seen.add(href);

      // Scan the labeled rows: Year is the first .opacity-70 row, so position
      // cannot be relied on.
      let status = null;
      if (metadata) {
        for (const strong of metadata.querySelectorAll('strong')) {
          if (strong.textContent.trim().includes('Status')) {
            status = strong.parentNode?.querySelector('span')?.textContent.trim() ?? null;
            break;
          }
        }
      }

      // The Tag row is the div holding a "Tag" strong - but a wrapper
      // CONTAINING that row matches too, and its own spans would pollute the
      // tag list. Pick the innermost match: the first row that is not an
      // ancestor of another.
      let tags = null;
      if (metadata) {
        const tagRows = [...metadata.querySelectorAll('div')].filter((div) =>
          (div.querySelector('strong')?.textContent ?? '').includes('Tag'),
        );
        const tagRow = tagRows.find(
          (row) => !tagRows.some((other) => other !== row && row.contains(other)),
        );
        if (tagRow) {
          tags = [...tagRow.querySelectorAll('span')]
            .map((span) => span.textContent.trim())
            .filter((text) => text !== '');
        }
      }

      items.push({
        title: link.textContent.trim(),
        coverUrl: ctx.absUrl(
          article.querySelector('img[src*="temp.compsci88.com"]')?.getAttribute('src') ?? null,
        ),
        webUrl: ctx.absUrl(href),
        status,
        author: metadata?.querySelector('a[href*="author="]')?.textContent.trim() ?? null,
        tags,
      });
    }

    // The server always renders a "View More Results..." button; a real next
    // page exists only when that button carries an `offset` param.
    const more = doc.querySelector('button[hx-get*="/search/data"]');
    return { items, hasNextPage: more?.getAttribute('hx-get')?.includes('offset=') ?? false };
  },

  // The series page renders the title in two <h1>s (mobile + desktop) with the
  // same text, so the first is fine. Rows are labeled by a <strong>; the
  // author sits in an <a>, the others in a <span>.
  manga(doc, ctx) {
    const rowValue = (label) => {
      for (const strong of doc.querySelectorAll('strong')) {
        if (!strong.textContent.trim().includes(label)) continue;
        const container = strong.parentNode;
        const value = container?.querySelector('span') ?? container?.querySelector('a');
        if (value) return value.textContent.trim();
      }
      return null;
    };

    let tags = null;
    for (const strong of doc.querySelectorAll('strong')) {
      if (!strong.textContent.trim().includes('Tag')) continue;
      tags = [...(strong.parentNode?.querySelectorAll('span') ?? [])]
        .map((span) => span.textContent.trim())
        .filter((text) => text !== '');
      break;
    }

    return {
      title: doc.querySelector('h1')?.textContent.trim() ?? null,
      author: rowValue('Author'),
      description:
        doc.querySelector('p.whitespace-pre-wrap.break-words')?.textContent.trim() ?? null,
      status: rowValue('Status'),
      tags,
      coverUrl: ctx.absUrl(
        doc.querySelector('main')?.querySelector('img[src*="temp.compsci88.com/cover"]')
          ?.getAttribute('src') ?? null,
      ),
    };
  },

  // The series page's #chapter-list only carries ~9 latest chapters; the
  // complete list is served by the endpoint the "Show All Chapters" htmx button
  // targets (#161). Stored webUrls may carry a trailing slash.
  chaptersUrl(webUrl, ctx) {
    const base = webUrl.endsWith('/') ? webUrl.slice(0, -1) : webUrl;
    return base + '/full-chapter-list';
  },

  // The full-chapter-list endpoint returns the htmx fragment that REPLACES
  // #chapter-list's inner HTML (no wrapper), so fall back to every chapter
  // anchor when the wrapper is absent.
  chapters(doc, ctx) {
    let rows = [...doc.querySelectorAll('#chapter-list a[href^="/chapters/"]')];
    if (rows.length === 0) rows = [...doc.querySelectorAll('a[href^="/chapters/"]')];

    const chapters = [];
    for (const row of rows) {
      const href = row.getAttribute('href');
      const title = row.querySelector('span.grow')?.querySelector('span')?.textContent.trim();
      // The unscoped fallback can see header/footer anchors matching the href
      // prefix: a row without its title cell is not a chapter row (#167).
      if (href === null || !title) continue;
      const time = row.querySelector('time')?.textContent.trim() ?? null;
      chapters.push({
        title,
        chapter: title.split(' ').pop(),
        webUrl: ctx.absUrl(href),
        readableAt: time,
        publishAt: time,
      });
    }
    return chapters;
  },

  // The reader loads page <img>s through an htmx swap that replaces
  // #chapter-images wholesale. The chapter id comes from the page URL
  // (/chapters/{id}); the same ajax the reader's Alpine init performs is
  // triggered with reading_style=long_strip so ALL pages are injected, then we
  // wait until the new section holds images.
  async images(doc, ctx) {
    const el = doc.getElementById('chapter-images');
    if (el && typeof htmx !== 'undefined') {
      const segments = location.pathname.split('/').filter(Boolean);
      const chapterId = segments[segments.length - 1];
      if (chapterId) {
        htmx.ajax(
          'GET',
          location.origin +
            '/chapters/' +
            chapterId +
            '/images?is_prev=False&current_page=1&reading_style=long_strip',
          { target: el, swap: 'outerHTML', values: { reading_style: 'long_strip' } },
        );
      }
    }
    await ctx.waitFor('section#chapter-images img');
    return [...doc.querySelectorAll('section#chapter-images img')]
      .map((img) => img.getAttribute('src'))
      .filter((src) => src !== null)
      .map((src) => ctx.absUrl(src));
  },

  // The genre checkboxes live ONLY on /search; searchUrl points at the
  // /search/data htmx fragment, which ships zero checkboxes (#163).
  tagsUrl(ctx) {
    return 'https://weebcentral.com/search';
  },

  // Checkboxes are shaped id="tag-{Name}" inside label.fieldset-label with the
  // human-readable name in the sibling <span class="ml-2">. The filter panel
  // sits behind the Alpine `show_filter` flag, so force it visible first.
  async tags(doc, ctx) {
    for (const panel of doc.querySelectorAll('section[x-show="show_filter"]')) {
      panel.style.display = 'block';
    }
    await ctx.waitFor('input[type="checkbox"][id^="tag-"]');

    const names = new Set();
    for (const input of doc.querySelectorAll('input[type="checkbox"][id^="tag-"]')) {
      const name = input.parentNode?.querySelector('span.ml-2')?.textContent.trim();
      if (name) names.add(name);
    }
    return [...names].map((name) => ({ id: name, name }));
  },
};
