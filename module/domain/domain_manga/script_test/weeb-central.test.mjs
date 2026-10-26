/**
 * Behavioural-parity tests for the Weeb Central JS source script
 * (../assets/sources/weeb-central.js). Every case mirrors one expectation of the
 * Dart test ../test/weeb_central_source_external_test.dart with the SAME expected
 * values, using fixtures ported verbatim to ./fixtures/weeb-central.
 *
 * How to run: `cd module/domain/domain_manga/script_test && npm ci && npm test`.
 */
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { parseHTML } from 'linkedom';

import { headerTimeoutMs, loadSource, recordWaitFor, runBlank, runPage } from './lib/load_source.mjs';

const SCRIPT = 'weeb-central.js';
const fixture = (name) =>
  readFileSync(
    fileURLToPath(new URL(`./fixtures/weeb-central/${name}.html`, import.meta.url)),
    'utf8',
  );
const page = (fn, name, opts) => runPage(SCRIPT, fn, fixture(name), opts);

const ONE_PIECE = 'https://weebcentral.com/series/01J76XY7E9FNDZ1DBBM6PBJPFK/One-Piece';

describe('identity', () => {
  test('header meta', () => {
    const { meta, source } = loadSource(SCRIPT);
    assert.equal(meta.id, 'weeb-central');
    assert.equal(meta.name, 'Weeb Central');
    assert.equal(meta.baseUrl, 'https://weebcentral.com');
    assert.equal(meta.iconUrl, 'https://weebcentral.com/favicon.ico');
    // 2: chaptersUrl drops the slug segment (A2 of the Android verification of
    // #115); the version drives the registry's 'update available'.
    assert.equal(meta.version, 2);
    assert.equal(meta.contract, 1);
    assert.deepEqual(meta.hosts, ['weebcentral.com', 'temp.compsci88.com']);
    assert.deepEqual(meta.timeouts, { images: 30000 });
    for (const fn of [
      'searchUrl',
      'search',
      'manga',
      'chaptersUrl',
      'chapters',
      'images',
      'tagsUrl',
      'tags',
    ]) {
      assert.equal(typeof source[fn], 'function', fn);
    }
  });
});

describe('search', () => {
  test('parses a result block', async () => {
    const { items } = await page('search', 'search');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'One Piece');
    assert.equal(items[0].webUrl, ONE_PIECE);
    assert.equal(items[0].status, 'Ongoing');
    assert.equal(items[0].author, 'ODA Eiichiro');
    assert.deepEqual(items[0].tags, ['Action', 'Adventure']);
    assert.equal(
      items[0].coverUrl,
      'https://temp.compsci88.com/cover/fallback/01J76XY7E9FNDZ1DBBM6PBJPFK.jpg',
    );
  });

  test('parses a redesigned card anchored on the series link', async () => {
    const { items } = await page('search', 'redesigned-card');
    assert.equal(items.length, 1);
    // The tooltip link to Bleach must not win over the metadata link.
    assert.equal(items[0].title, 'One Piece');
    assert.equal(items[0].webUrl, ONE_PIECE);
    assert.equal(items[0].status, 'Ongoing');
    assert.equal(items[0].author, 'ODA Eiichiro');
  });

  test('skips nested, text-row and image-only article traps', async () => {
    const { items } = await page('search', 'search-traps');
    // The nested inner article, the no-cover text row and the image-only
    // recommendation must not become cards - only the outer One Piece card.
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'One Piece');
    assert.equal(items[0].webUrl, ONE_PIECE);
  });

  test('prefers the first metadata section over a later tooltip section', async () => {
    const { items } = await page('search', 'tooltip-in-section');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'One Piece');
    assert.equal(items[0].status, 'Ongoing');
  });

  test('takes the innermost Tag row, not a nested wrapper', async () => {
    const { items } = await page('search', 'nested-tag-row');
    // The wrapper div also matches "has a Tag strong descendant" - its badge
    // span must not leak into the tags.
    assert.equal(items.length, 1);
    assert.deepEqual(items[0].tags, ['Action', 'Adventure']);
  });

  test('picks the strong-row section over the ribbon-bearing cover section (#162)', async () => {
    const { items } = await page('search', 'official-ribbon-card');
    assert.equal(items.length, 1);
    // Not "Official Kobato." - the ribbon + overlay title live inside the
    // cover anchor, which must not be mistaken for the metadata link.
    assert.equal(items[0].title, 'Kobato.');
    assert.equal(items[0].status, 'Complete');
    assert.equal(items[0].author, 'CLAMP');
    assert.deepEqual(items[0].tags, ['Comedy', 'Romance']);
    assert.equal(
      items[0].coverUrl,
      'https://temp.compsci88.com/cover/fallback/01J76XY7E2VCSR0ZCC21KGXS1K.jpg',
    );
  });

  test('ignores a colon-less strong badge in an earlier tooltip section (review on #169)', async () => {
    const { items } = await page('search', 'tooltip-strong-first-card');
    assert.equal(items.length, 1);
    // The tooltip links to a different series and carries <strong>New</strong>
    // - only labeled rows (colon-bearing strongs) identify metadata.
    assert.equal(items[0].title, 'One Piece');
    assert.ok(items[0].webUrl.includes('One-Piece'));
    assert.equal(items[0].status, 'Ongoing');
    assert.equal(items[0].author, 'ODA Eiichiro');
  });

  test('degrades to a metadata section, never the cover (review on #169)', async () => {
    const { items } = await page('search', 'strongless-card');
    assert.equal(items.length, 2);
    // Strong-less layout: the cover ships first, so the degraded pick is the
    // LAST text-link section - not the first, which is the cover anchor
    // carrying the ribbon + overlay title.
    assert.equal(items[0].title, 'Kobato.');
    assert.equal(items[0].author, 'CLAMP');
    // ...and the fallback must be order-proof: with metadata shipping FIRST, a
    // cover-last section must not win the pick either.
    assert.equal(items[1].title, 'One Piece');
    assert.equal(items[1].author, 'ODA Eiichiro');
  });

  test('hasNextPage false when no view-more button', async () => {
    const { hasNextPage } = await page('search', 'search');
    assert.equal(hasNextPage, false);
  });

  test('hasNextPage true when the view-more button carries an offset', async () => {
    const { hasNextPage } = await page('search', 'next-page');
    assert.equal(hasNextPage, true);
  });

  test('hasNextPage false when the view-more button has no offset', async () => {
    const { hasNextPage } = await page('search', 'last-page');
    assert.equal(hasNextPage, false);
  });
});

describe('manga (series page)', () => {
  test('parses series page', async () => {
    const manga = await page('manga', 'series');
    assert.equal(manga.title, 'One Piece');
    assert.equal(manga.author, 'ODA Eiichiro');
    assert.equal(manga.description, 'A pirate adventure.');
    assert.equal(manga.status, 'Ongoing');
    assert.deepEqual(manga.tags, ['Action', 'Adventure']);
  });

  test('cover is read from main (the Dart source only looks inside <main>)', async () => {
    // The Dart fixture has no <main>, so coverUrl is null there; with a main
    // wrapper the temp.compsci88.com cover is returned.
    assert.equal((await page('manga', 'series')).coverUrl ?? null, null);
    const html = '<html><body><main><img src="https://temp.compsci88.com/cover/x.jpg"></main></body></html>';
    const manga = await runPage(SCRIPT, 'manga', html);
    assert.equal(manga.coverUrl, 'https://temp.compsci88.com/cover/x.jpg');
  });
});

describe('chapters', () => {
  test('parses rows in order', async () => {
    const chapters = await page('chapters', 'series');
    assert.equal(chapters.length, 2);
    assert.equal(chapters[0].title, 'Chapter 1190');
    assert.equal(chapters[0].chapter, '1190');
    assert.equal(chapters[0].webUrl, 'https://weebcentral.com/chapters/01KZECDZH06AWDQEJZAAQA9C2P');
    assert.equal(chapters[0].publishAt, '2026-08-07T15:10:56.544424Z');
    assert.equal(chapters[0].readableAt, '2026-08-07T15:10:56.544424Z');
  });

  test('parses the full-chapter-list fragment (no #chapter-list wrapper)', async () => {
    const chapters = await page('chapters', 'full-chapter-list-fragment');
    assert.equal(chapters.length, 3);
    assert.equal(chapters[0].title, 'Chapter 102');
    assert.equal(chapters[0].chapter, '102');
    assert.equal(chapters[0].webUrl, 'https://weebcentral.com/chapters/01J76XZ3HXP7R4R9NT922FEVNQ');
    assert.equal(chapters[0].publishAt, '2024-09-08T17:04:15.717343Z');
    assert.equal(chapters[1].chapter, '101.5');
  });

  test('fallback skips anchors without a title row (review on #167)', async () => {
    // The unscoped fallback fires whenever #chapter-list is missing - header /
    // footer anchors matching the href prefix must not become null-title chapters.
    const html = `
      <div>
        <nav><a href="/chapters/latest">Latest Updates</a></nav>
        <a href="/chapters/01J76XZ3HXP7R4R9NQ">
          <span class="grow"><span>Chapter 102</span></span>
          <time>2024-09-08T17:04:15Z</time>
        </a>
        <footer><a href="/chapters/feed">RSS</a></footer>
      </div>`;
    const chapters = await runPage(SCRIPT, 'chapters', html);
    assert.equal(chapters.length, 1);
    assert.equal(chapters[0].title, 'Chapter 102');
  });

  test('chaptersUrl points at the full-chapter-list endpoint (equals the Dart url())', async () => {
    // The series page renders only ~9 latest chapters; the complete list
    // (102 rows for Beck, verified live 2026-10) is served from this endpoint.
    const seriesUrl = 'https://weebcentral.com/series/01J76XY7E3JVY2XJGG8VGP46NN';
    assert.equal(
      await runBlank(SCRIPT, 'chaptersUrl', seriesUrl),
      `${seriesUrl}/full-chapter-list`,
    );
  });

  // Site change (live 2026-10, Android verification of #115): cards from
  // search/browse store webUrls WITH the slug segment, and weebcentral.com now
  // answers /series/<id>/<slug>/full-chapter-list with a 307 to /404; only
  // /series/<id>/full-chapter-list returns the rows. This deliberately differs
  // from the former Dart url() (webUrl + '/full-chapter-list'), which the
  // pinned value above equalled for slug-less webUrls only.
  test('chaptersUrl drops the slug segment of a stored webUrl', async () => {
    const id = '01J76XY7EF75DJNQCV04HTPDZK';
    const expected = `https://weebcentral.com/series/${id}/full-chapter-list`;
    for (const webUrl of [
      `https://weebcentral.com/series/${id}/Berserk`,
      `https://weebcentral.com/series/${id}/Berserk/`,
      `https://weebcentral.com/series/${id}/`,
      `https://weebcentral.com/series/${id}`,
    ]) {
      assert.equal(await runBlank(SCRIPT, 'chaptersUrl', webUrl), expected, webUrl);
    }
  });

  test('chaptersUrl tolerates a trailing slash on the stored webUrl (review on #167)', async () => {
    const seriesUrl = 'https://weebcentral.com/series/01J76XY7E3JVY2XJGG8VGP46NN/';
    assert.equal(
      await runBlank(SCRIPT, 'chaptersUrl', seriesUrl),
      'https://weebcentral.com/series/01J76XY7E3JVY2XJGG8VGP46NN/full-chapter-list',
    );
  });
});

describe('searchUrl', () => {
  // SearchMangaParameter.toJson() encodes enums by NAME (orders: {rating:
  // 'descending'}, status: ['ongoing']), see search_manga_parameter.g.dart; the
  // generated map also carries null for absent fields.
  test('maps sort, order, status, tags', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', {
        title: 'One Piece',
        limit: 32,
        page: 1,
        orders: { rating: 'descending' },
        status: ['ongoing'],
        includedTags: ['Action', 'Adventure'],
      }),
      'https://weebcentral.com/search/data' +
        '?text=One+Piece&limit=32&offset=0&display_mode=Full+Display' +
        '&sort=Popularity&order=Descending&included_status=Ongoing' +
        '&included_tag=Action&included_tag=Adventure',
    );
  });

  test('hardcodes the server page size', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'One Piece', limit: 20, page: 2 }),
      'https://weebcentral.com/search/data' +
        '?text=One+Piece&limit=32&offset=32&display_mode=Full+Display',
    );
  });

  test('empty title and null fields still build the browse listing', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', {
        title: null,
        page: 1,
        orders: null,
        status: null,
        includedTags: null,
      }),
      'https://weebcentral.com/search/data?text=&limit=32&offset=0&display_mode=Full+Display',
    );
  });

  test('order mapping covers every Dart SearchOrders case', async () => {
    const url = (orders) => runBlank(SCRIPT, 'searchUrl', { page: 1, orders });
    const base = 'https://weebcentral.com/search/data?text=&limit=32&offset=0&display_mode=Full+Display';
    const cases = {
      title: 'Alphabet',
      relevance: 'Best Match',
      followedCount: 'Subscribers',
      createdAt: 'Recently Added',
      latestUploadedChapter: 'Latest Updates',
      rating: 'Popularity',
    };
    for (const [key, sort] of Object.entries(cases)) {
      assert.equal(
        await url({ [key]: 'ascending' }),
        `${base}&sort=${sort.replace(' ', '+')}&order=Ascending`,
        key,
      );
    }
    // Unmapped keys send the direction only, exactly like the Dart `_ => null`.
    assert.equal(await url({ year: 'descending' }), `${base}&order=Descending`);
    assert.equal(await url({ updatedAt: 'ascending' }), `${base}&order=Ascending`);
  });

  test('status mapping uses only the first status (Dart firstOrNull)', async () => {
    const url = (status) => runBlank(SCRIPT, 'searchUrl', { page: 1, status });
    const base = 'https://weebcentral.com/search/data?text=&limit=32&offset=0&display_mode=Full+Display';
    assert.equal(await url(['ongoing', 'completed']), `${base}&included_status=Ongoing`);
    assert.equal(await url(['completed']), `${base}&included_status=Complete`);
    assert.equal(await url(['hiatus']), `${base}&included_status=Hiatus`);
    assert.equal(await url(['cancelled']), `${base}&included_status=Canceled`);
    assert.equal(await url([]), base);
  });

  test('query components are percent-encoded like Uri.encodeQueryComponent', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: "Tom & Jerry's (1+1)*!", page: 1 }),
      'https://weebcentral.com/search/data' +
        '?text=Tom+%26+Jerry%27s+%281%2B1%29%2A%21&limit=32&offset=0&display_mode=Full+Display',
    );
  });
});

describe('reader', () => {
  test('parses orders srcs and keeps onerror images', async () => {
    const images = await page('images', 'images');
    assert.deepEqual(images, [
      'https://temp.compsci88.com/manga/One-Piece/1190-001.png',
      'https://temp.compsci88.com/manga/One-Piece/1190-002.png',
      'https://temp.compsci88.com/manga/One-Piece/1190-003.png',
    ]);
  });

  test('rejects with waitFor timeout when the page images never appear', async () => {
    // Same selector the Dart source declared in readyWhenSelectors.
    await assert.rejects(
      runPage(SCRIPT, 'images', '<html><body></body></html>', { waitTimeoutMs: 150 }),
      /waitFor timed out: section#chapter-images img/,
    );
  });

  test('triggers the htmx long_strip ajax derived from the page URL', async () => {
    const calls = [];
    globalThis.htmx = { ajax: (...args) => calls.push(args) };
    globalThis.location = {
      pathname: '/chapters/01KZECDZH06AWDQEJZAAQA9C2P',
      origin: 'https://weebcentral.com',
    };
    try {
      await page('images', 'images');
    } finally {
      delete globalThis.htmx;
      delete globalThis.location;
    }
    assert.equal(calls.length, 1);
    const [method, url, options] = calls[0];
    assert.equal(method, 'GET');
    assert.equal(
      url,
      'https://weebcentral.com/chapters/01KZECDZH06AWDQEJZAAQA9C2P' +
        '/images?is_prev=False&current_page=1&reading_style=long_strip',
    );
    assert.equal(options.swap, 'outerHTML');
    assert.deepEqual(options.values, { reading_style: 'long_strip' });
    assert.equal(options.target.id, 'chapter-images');
  });
});

describe('tags', () => {
  test('parses genre checkboxes', async () => {
    const tags = await page('tags', 'tag-panel');
    assert.equal(tags.length, 2);
    assert.equal(tags[0].id, 'Action');
    assert.equal(tags[0].name, 'Action');
    assert.equal(tags[1].id, 'Adventure');
    assert.equal(tags[1].name, 'Adventure');
  });

  test('forces the hidden filter panel visible (show_filter)', async () => {
    const { meta, source, createSourceCtx } = loadSource(SCRIPT);
    const doc = parseHTML(fixture('tag-panel')).document;
    const ctx = createSourceCtx({ doc, baseUrl: meta.baseUrl });
    await source.tags(doc, ctx);
    const panel = doc.querySelector('section[x-show="show_filter"]');
    assert.equal(panel.style.display, 'block');
  });

  test('tagsUrl points at the /search page (#163, equals the Dart url)', async () => {
    // The genre checkboxes live ONLY on /search; searchUrl points at the
    // /search/data htmx fragment, which ships zero checkboxes.
    assert.equal(await runBlank(SCRIPT, 'tagsUrl'), 'https://weebcentral.com/search');
  });
});

describe('readiness budgets', () => {
  // Master waited for the readiness selector within the hook timeout; the 10 s
  // ctx default would fail slow chapter/genre pages earlier than before.
  // The wait must end BEFORE the runner's own timeout (header timeout), or a
  // stale selector yields the generic runner timeout with no page HTML instead
  // of the clean `waitFor timed out: <selector>` error.
  test('images waits 3000 ms less than the header timeouts.images', async () => {
    const { meta } = loadSource(SCRIPT);
    const calls = await recordWaitFor(SCRIPT, 'images');
    assert.deepEqual(calls, [['section#chapter-images img', 27000]]);
    assert.ok(calls[0][1] < headerTimeoutMs(meta, 'images'));
    assert.equal(meta.timeouts.images, 30000);
  });

  test('tags waits 3000 ms less than the default 15 s budget (no header override)', async () => {
    const { meta } = loadSource(SCRIPT);
    const calls = await recordWaitFor(SCRIPT, 'tags');
    assert.deepEqual(calls, [['input[type="checkbox"][id^="tag-"]', 12000]]);
    assert.ok(calls[0][1] < headerTimeoutMs(meta, 'tags'));
  });
});
