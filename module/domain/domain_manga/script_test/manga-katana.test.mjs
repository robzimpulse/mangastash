/**
 * Behavioural-parity tests for the Manga Katana JS source script
 * (../assets/sources/manga-katana.js). Every case mirrors one expectation of the
 * Dart test ../test/mangakatana_source_external_test.dart with the SAME expected
 * values and fixtures ported verbatim to ./fixtures/manga-katana, with ONE
 * deliberate change (spec section 11): search cards no longer return `tags`,
 * because `div.item[data-genre]` holds numeric genre ids, never names (verified
 * live 2026-10-11), and ids must not be stored as tag names.
 *
 * How to run: `cd module/domain/domain_manga/script_test && npm ci && npm test`.
 */
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { loadSource, runBlank, runPage } from './lib/load_source.mjs';

const SCRIPT = 'manga-katana.js';
const fixture = (name) =>
  readFileSync(
    fileURLToPath(new URL(`./fixtures/manga-katana/${name}.html`, import.meta.url)),
    'utf8',
  );
const page = (fn, name, opts) => runPage(SCRIPT, fn, fixture(name), opts);

describe('identity', () => {
  test('header meta', () => {
    const { meta, source } = loadSource(SCRIPT);
    assert.equal(meta.id, 'manga-katana');
    assert.equal(meta.name, 'Manga Katana');
    assert.equal(meta.baseUrl, 'https://mangakatana.com');
    assert.equal(meta.iconUrl, 'https://mangakatana.com/favicon.ico');
    assert.equal(meta.version, 1);
    assert.equal(meta.contract, 1);
    assert.deepEqual(meta.hosts, ['mangakatana.com', 'mkcdn.mangakatana.com']);
    assert.deepEqual(meta.timeouts, { images: 30000 });
    for (const fn of ['searchUrl', 'search', 'manga', 'chapters', 'images', 'tagsUrl', 'tags']) {
      assert.equal(typeof source[fn], 'function', fn);
    }
    // Optional: the series page itself carries the chapter list.
    assert.equal(source.chaptersUrl, undefined);
  });
});

describe('searchUrl', () => {
  test('maps title to root path and ignores page 1', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'One Piece' }),
      'https://mangakatana.com/?search=One+Piece&search_by=m_name',
    );
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'One Piece', page: 1 }),
      'https://mangakatana.com/?search=One+Piece&search_by=m_name',
    );
  });

  test('maps page 2+ of a query to the paginated search route (#165)', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'sword', page: 2 }),
      'https://mangakatana.com/page/2?search=sword&search_by=m_name',
    );
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'sword', page: 3 }),
      'https://mangakatana.com/page/3?search=sword&search_by=m_name',
    );
  });

  test('maps empty title to the homepage (search page is empty after JS)', async () => {
    assert.equal(await runBlank(SCRIPT, 'searchUrl', {}), 'https://mangakatana.com/');
    // SearchMangaParameter.toJson() sends null for absent fields.
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: null, page: 1 }),
      'https://mangakatana.com/',
    );
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: '', page: 1 }),
      'https://mangakatana.com/',
    );
  });

  test('maps page 2+ of an empty query to the /page/N route', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { page: 2 }),
      'https://mangakatana.com/page/2',
    );
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { page: 7 }),
      'https://mangakatana.com/page/7',
    );
  });

  test('query is percent-encoded like Uri.encodeQueryComponent', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: "Tom & Jerry's (1+1)*!", page: 1 }),
      'https://mangakatana.com/?search=Tom+%26+Jerry%27s+%281%2B1%29%2A%21&search_by=m_name',
    );
  });
});

describe('search', () => {
  test('parses root-search .media template items', async () => {
    const { items } = await page('search', 'search-root');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'One Piece');
    assert.equal(items[0].webUrl, 'https://mangakatana.com/manga/one-piece.49');
    assert.equal(items[0].coverUrl, 'https://mangakatana.com/imgs/cover/04e/01/dc9fd.jpg');
    assert.equal(items[0].status, 'Ongoing');
  });

  test('parses a result block with absolute webUrl', async () => {
    const { items } = await page('search', 'search');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'One Piece');
    assert.equal(items[0].webUrl, 'https://mangakatana.com/manga/one-piece.123');
    assert.equal(items[0].coverUrl, 'https://mkcdn.mangakatana.com/cover/one-piece.jpg');
    assert.equal(items[0].status, 'Ongoing');
    // Behaviour change vs Dart (spec section 11): data-genre never reaches tags.
    assert.equal(items[0].tags, undefined);
  });

  test('numeric data-genre ids never reach tags', async () => {
    const { items } = await page('search', 'search-numeric-genre');
    assert.equal(items.length, 2);
    // ",14,15,2," (live shape) and "14,15,2" alike.
    assert.equal(items[0].tags, undefined);
    assert.equal(items[1].tags, undefined);
    assert.equal(items[1].title, 'Bleach');
    assert.ok(!JSON.stringify(items).includes('"14"'));
  });

  test('page 2 parses cards and reports the next page (review on #168)', async () => {
    const { items, hasNextPage } = await page('search', 'search-page-2');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'Sword Master');
    assert.equal(items[0].webUrl, 'https://mangakatana.com/manga/sword-master.777');
    assert.equal(hasNextPage, true);
  });

  test('browse scopes cards to #book_list (ignores #hot_book sidebar)', async () => {
    const { items } = await page('search', 'browse');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'Latest Manga');
  });

  test('hasNextPage true when the pagination nav has a next link', async () => {
    assert.equal((await page('search', 'browse')).hasNextPage, true);
  });

  test('hasNextPage false on the last page', async () => {
    assert.equal((await page('search', 'browse-last-page')).hasNextPage, false);
  });

  test('hasNextPage false when the page has no pagination nav', async () => {
    assert.equal((await page('search', 'search')).hasNextPage, false);
  });
});

describe('manga (detail)', () => {
  test('parses series page', async () => {
    const manga = await page('manga', 'detail');
    assert.equal(manga.title, 'One Piece');
    assert.equal(manga.author, 'ODA Eiichiro');
    assert.equal(manga.status, 'Ongoing');
    assert.equal(
      manga.description,
      'Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.',
    );
    assert.deepEqual(manga.tags, ['Action', 'Adventure']);
  });

  test('parses the live d-row-small rows with absolute genre hrefs (#164)', async () => {
    const manga = await page('manga', 'detail-live');
    assert.equal(manga.title, 'A Cool Girl and a 12cm Promise');
    assert.equal(manga.author, 'Ziki Masaya');
    assert.equal(manga.status, 'Ongoing');
    // The navbar genre dropdown (plain <li>) must not leak into the tags.
    assert.deepEqual(manga.tags, ['Comedy', 'Romance', 'Slice of Life']);
    assert.equal(manga.description, 'A cool girl story.');
  });

  test('cover prefers data-src, then src, of the wrap_img image', async () => {
    const withData =
      '<div class="wrap_img"><img data-src="https://mkcdn.mangakatana.com/c.jpg" src="/x.jpg"></div>';
    assert.equal(
      (await runPage(SCRIPT, 'manga', withData)).coverUrl,
      'https://mkcdn.mangakatana.com/c.jpg',
    );
    const srcOnly = '<div class="wrap_img"><img src="/imgs/cover/y.jpg"></div>';
    assert.equal(
      (await runPage(SCRIPT, 'manga', srcOnly)).coverUrl,
      'https://mangakatana.com/imgs/cover/y.jpg',
    );
    assert.equal((await page('manga', 'detail')).coverUrl ?? null, null);
  });
});

describe('chapters', () => {
  test('parses table rows in order', async () => {
    const chapters = await page('chapters', 'detail');
    assert.equal(chapters.length, 2);
    assert.equal(chapters[0].title, 'Chapter 1040');
    assert.equal(chapters[0].chapter, '1040');
    assert.equal(chapters[0].webUrl, 'https://mangakatana.com/manga/one-piece.123/c1040');
    assert.equal(chapters[0].publishAt, 'August 7, 2026');
    assert.equal(chapters[0].readableAt, 'August 7, 2026');
    assert.equal(chapters[1].chapter, '1039');
  });

  test('chapter number falls back to the last word, keeps decimals', async () => {
    const html = `<table>
      <tr><td><div class="chapter"><a href="/manga/x.1/c12.5">Ch 12.5 extra</a></div></td></tr>
      <tr><td><div class="chapter"><a href="/manga/x.1/special">Special Edition</a></div></td></tr>
    </table>`;
    const chapters = await runPage(SCRIPT, 'chapters', html);
    assert.equal(chapters[0].chapter, '12.5');
    assert.equal(chapters[0].webUrl, 'https://mangakatana.com/manga/x.1/c12.5');
    assert.equal(chapters[1].chapter, 'Edition');
  });
});

describe('reader', () => {
  test('parses data-srcs and drops unresolved placeholders', async () => {
    const images = await page('images', 'reader');
    assert.deepEqual(images, [
      'https://mkcdn.mangakatana.com/manga/one-piece.123/1040/1.jpg',
      'https://mkcdn.mangakatana.com/manga/one-piece.123/1040/2.jpg',
    ]);
  });

  test('copies the inline thzq array into the data-src placeholders', async () => {
    // The page declares `var thzq = [...]` inline; the reader <img>s only carry
    // data-src="#" placeholders (the Dart source injected a script for this).
    const html = `<div id="imgs">
      <div class="wrap_img"><img data-src="#"></div>
      <div class="wrap_img"><img data-src="#"></div>
      <div class="wrap_img"><img data-src="#"></div>
    </div>`;
    globalThis.thzq = [
      'https://mkcdn.mangakatana.com/a/1.jpg',
      'https://mkcdn.mangakatana.com/a/2.jpg',
    ];
    try {
      assert.deepEqual(await runPage(SCRIPT, 'images', html), [
        'https://mkcdn.mangakatana.com/a/1.jpg',
        'https://mkcdn.mangakatana.com/a/2.jpg',
      ]);
    } finally {
      delete globalThis.thzq;
    }
  });

  test('rejects with waitFor timeout when the reader images never appear', async () => {
    await assert.rejects(
      runPage(SCRIPT, 'images', '<html><body></body></html>', { waitTimeoutMs: 150 }),
      /waitFor timed out: #imgs \.wrap_img img/,
    );
  });
});

describe('tags', () => {
  test('parses genre index links', async () => {
    const tags = await page('tags', 'genres');
    assert.equal(tags.length, 3);
    assert.equal(tags[0].id, 'action');
    assert.equal(tags[0].name, 'Action');
    assert.deepEqual(tags[2], { id: 'comedy', name: 'Comedy' });
  });

  test('dedupes by name (last slug wins) and skips blank names', async () => {
    const html = `<a href="/genre/action">Action</a><a href="/genre/action-2/">Action</a>
      <a href="/genre/slice-of-life">Slice of Life</a><a href="/genre/empty"> </a>`;
    assert.deepEqual(await runPage(SCRIPT, 'tags', html), [
      { id: 'action-2', name: 'Action' },
      { id: 'slice-of-life', name: 'Slice of Life' },
    ]);
  });

  test('tagsUrl is null: genres come from the page searchUrl already opens', async () => {
    assert.equal(await runBlank(SCRIPT, 'tagsUrl'), null);
  });
});
