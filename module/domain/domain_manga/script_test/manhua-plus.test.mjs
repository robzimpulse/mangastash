/**
 * Behavioural-parity tests for the Manhua Plus JS source script
 * (../assets/sources/manhua-plus.js). Every case mirrors one expectation of the
 * Dart test ../test/manhua_plus_source_external_test.dart with the SAME expected
 * values and fixtures ported verbatim to ./fixtures/manhua-plus, plus a few
 * extra cases for the documented deviations (blank reader srcs, link-less
 * chapter rows) and for dedupe / fallback selectors.
 *
 * How to run: `cd module/domain/domain_manga/script_test && npm ci && npm test`.
 */
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { loadSource, runBlank, runPage } from './lib/load_source.mjs';

const SCRIPT = 'manhua-plus.js';
const fixture = (name) =>
  readFileSync(
    fileURLToPath(new URL(`./fixtures/manhua-plus/${name}.html`, import.meta.url)),
    'utf8',
  );
const page = (fn, name, opts) => runPage(SCRIPT, fn, fixture(name), opts);

describe('identity', () => {
  test('header meta', () => {
    const { meta, source } = loadSource(SCRIPT);
    assert.equal(meta.id, 'manhua-plus');
    assert.equal(meta.name, 'Manhua Plus');
    assert.equal(meta.baseUrl, 'https://manhuaplus.com');
    assert.equal(meta.iconUrl, 'https://manhuaplus.com/favicon.ico');
    assert.equal(meta.version, 1);
    assert.equal(meta.contract, 1);
    assert.deepEqual(meta.hosts, ['manhuaplus.com', 'cdn.mhpcdn.com']);
    assert.deepEqual(meta.timeouts, { images: 30000 });
    for (const fn of ['searchUrl', 'search', 'manga', 'chapters', 'images', 'tagsUrl', 'tags']) {
      assert.equal(typeof source[fn], 'function', fn);
    }
    // Optional: the series page itself carries the chapter list.
    assert.equal(source.chaptersUrl, undefined);
  });
});

describe('searchUrl', () => {
  test('maps title to Madara query', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'One Piece' }),
      'https://manhuaplus.com/?s=One+Piece',
    );
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'One Piece', page: 1 }),
      'https://manhuaplus.com/?s=One+Piece',
    );
  });

  test('maps page 2 to paginated search path', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: 'One Piece', page: 2 }),
      'https://manhuaplus.com/page/2/?s=One+Piece',
    );
  });

  test('maps empty title to homepage (search page is empty)', async () => {
    assert.equal(await runBlank(SCRIPT, 'searchUrl', {}), 'https://manhuaplus.com/');
    // SearchMangaParameter.toJson() sends null for absent fields.
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: null, page: 1 }),
      'https://manhuaplus.com/',
    );
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: '', page: 1 }),
      'https://manhuaplus.com/',
    );
    assert.equal(await runBlank(SCRIPT, 'searchUrl', { page: 2 }), 'https://manhuaplus.com/page/2/');
  });

  test('query is percent-encoded like Uri.encodeQueryComponent', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { title: "Tom & Jerry's (1+1)*!", page: 2 }),
      'https://manhuaplus.com/page/2/?s=Tom+%26+Jerry%27s+%281%2B1%29%2A%21',
    );
  });
});

describe('search', () => {
  test('parses a slider__item result block with absolute webUrl', async () => {
    const { items } = await page('search', 'search');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'Martial Peak');
    assert.equal(items[0].webUrl, 'https://manhuaplus.com/manga/martial-peak/');
    assert.equal(
      items[0].coverUrl,
      'https://manhuaplus.com/wp-content/uploads/2020/07/thumbbbbb-125x180.jpg',
    );
  });

  test('parses archive page-item-detail cards', async () => {
    const { items } = await page('search', 'search-archive');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'I Am the Fated Villain');
    assert.equal(items[0].webUrl, 'https://manhuaplus.com/manga/i-am-the-fated-villain/');
    assert.equal(
      items[0].coverUrl,
      'https://manhuaplus.com/wp-content/uploads/2024/01/3-1-175x238.jpg',
    );
  });

  test('page-item-detail card without h4 link or title attribute is skipped', async () => {
    // Dart: h3 titles do not match `h4 a`, and `div.item-thumb a[title]` needs a
    // title attribute, so the card is dropped.
    const { items } = await page('search', 'no-next-page');
    assert.deepEqual(items, []);
  });

  test('falls back to a[href*="/manga/"] and src covers in slider cards', async () => {
    const html = `<div class="slider__item"><div class="item__wrap">
      <div class="slider__thumb"><img src="/wp-content/uploads/c.jpg"></div>
      <a href="/manga/foo/"> Foo </a></div></div>`;
    const { items } = await runPage(SCRIPT, 'search', html);
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'Foo');
    assert.equal(items[0].webUrl, 'https://manhuaplus.com/manga/foo/');
    assert.equal(items[0].coverUrl, 'https://manhuaplus.com/wp-content/uploads/c.jpg');
  });

  test('dedupes cards by href across slider and archive blocks', async () => {
    const html = `
      <div class="slider__item"><div class="item__wrap">
        <div class="post-title"><h4><a href="/manga/a/">A</a></h4></div></div></div>
      <div class="page-item-detail"><div class="item-summary"><div class="post-title">
        <h4><a href="/manga/a/">A again</a></h4></div></div></div>
      <div class="page-item-detail"><div class="item-summary"><div class="post-title">
        <h4><a href="/manga/b/">B</a></h4></div></div></div>`;
    const { items } = await runPage(SCRIPT, 'search', html);
    assert.deepEqual(
      items.map((i) => [i.title, i.webUrl]),
      [
        ['A', 'https://manhuaplus.com/manga/a/'],
        ['B', 'https://manhuaplus.com/manga/b/'],
      ],
    );
  });

  test('hasNextPage false without a next-page link', async () => {
    assert.equal((await page('search', 'no-next-page')).hasNextPage, false);
  });

  test('hasNextPage true when a.next.page-numbers is present', async () => {
    assert.equal((await page('search', 'next-page')).hasNextPage, true);
  });

  test('hasNextPage true for a wp-pagenavi .next link', async () => {
    const html = '<div class="wp-pagenavi"><a class="nextpostslink next" href="/page/2/">Next</a></div>';
    assert.equal((await runPage(SCRIPT, 'search', html)).hasNextPage, true);
  });
});

describe('manga (detail)', () => {
  test('parses series page', async () => {
    const manga = await page('manga', 'detail');
    assert.equal(manga.title, 'One Piece');
    assert.equal(manga.author, 'ODA Eiichiro');
    assert.equal(manga.status, 'OnGoing');
    assert.equal(
      manga.description,
      'Monkey D. Luffy sets sail to find the One Piece in a pirate adventure.',
    );
    assert.deepEqual(manga.tags, ['Action', 'Adventure']);
    assert.equal(manga.coverUrl, 'https://manhuaplus.com/wp-content/uploads/2025/01/one-piece.jpg');
  });

  test('description falls back to div.summary__content p', async () => {
    const html = '<div class="summary__content"><p> Fallback text </p></div>';
    assert.equal((await runPage(SCRIPT, 'manga', html)).description, 'Fallback text');
  });

  test('cover prefers data-src over src of the tab-summary image', async () => {
    const html =
      '<div class="tab-summary"><img data-src="https://manhuaplus.com/d.jpg" src="/x.jpg"></div>';
    assert.equal((await runPage(SCRIPT, 'manga', html)).coverUrl, 'https://manhuaplus.com/d.jpg');
  });

  test('missing fields come back null / empty', async () => {
    const manga = await runPage(SCRIPT, 'manga', '<html><body></body></html>');
    assert.equal(manga.title ?? null, null);
    assert.equal(manga.author ?? null, null);
    assert.equal(manga.status ?? null, null);
    assert.equal(manga.description ?? null, null);
    assert.equal(manga.coverUrl ?? null, null);
    assert.deepEqual(manga.tags, []);
  });
});

describe('chapters', () => {
  test('parses rows in order', async () => {
    const chapters = await page('chapters', 'detail');
    assert.equal(chapters.length, 2);
    assert.equal(chapters[0].title, 'Chapter 1100');
    assert.equal(chapters[0].chapter, '1100');
    assert.equal(chapters[0].webUrl, 'https://manhuaplus.com/manga/one-piece/chapter-1100/');
    assert.equal(chapters[0].publishAt, 'August 7, 2026');
    assert.equal(chapters[0].readableAt, 'August 7, 2026');
    assert.equal(chapters[1].chapter, '1099');
  });

  test('chapter number falls back to the last word, keeps decimals', async () => {
    const html = `<ul>
      <li class="wp-manga-chapter"><a href="/manga/x/ch-12-5/">Ch 12.5 extra</a></li>
      <li class="wp-manga-chapter"><a href="/manga/x/special/">Special Edition</a></li></ul>`;
    const chapters = await runPage(SCRIPT, 'chapters', html);
    assert.equal(chapters[0].chapter, '12.5');
    assert.equal(chapters[0].webUrl, 'https://manhuaplus.com/manga/x/ch-12-5/');
    assert.equal(chapters[0].publishAt ?? null, null);
    assert.equal(chapters[1].chapter, 'Edition');
  });

  test('rows without a link are skipped (deviation: Dart emitted all-null rows)', async () => {
    const html = '<li class="wp-manga-chapter">no link</li>';
    assert.deepEqual(await runPage(SCRIPT, 'chapters', html), []);
  });
});

describe('reader', () => {
  test('parses real srcs', async () => {
    assert.deepEqual(await page('images', 'reader'), [
      'https://cdn.mhpcdn.com/op/1100/1.jpg',
      'https://cdn.mhpcdn.com/op/1100/2.jpg',
      'https://cdn.mhpcdn.com/op/1100/3.jpg',
    ]);
  });

  test('copies lazyload data-src into src before reading', async () => {
    const html = `<div class="reading-content">
      <img class="wp-manga-chapter-img" src="data:image/gif;base64,R0lGOD" data-src="
        https://cdn.mhpcdn.com/a/1.jpg ">
      <img data-src="/wp-content/uploads/a/2.jpg">
      <img src="https://cdn.mhpcdn.com/a/3.jpg">
      <img src="">
      <img>
    </div><img src="https://cdn.mhpcdn.com/outside.jpg">`;
    assert.deepEqual(await runPage(SCRIPT, 'images', html), [
      'https://cdn.mhpcdn.com/a/1.jpg',
      'https://manhuaplus.com/wp-content/uploads/a/2.jpg',
      'https://cdn.mhpcdn.com/a/3.jpg',
    ]);
  });

  test('returns [] when the page has no reader images (like Dart; no waitFor)', async () => {
    assert.deepEqual(await runPage(SCRIPT, 'images', '<html><body></body></html>'), []);
  });
});

describe('tags', () => {
  test('parses genre page links', async () => {
    const tags = await page('tags', 'genres');
    assert.equal(tags.length, 3);
    assert.equal(tags[0].id, 'action');
    assert.equal(tags[0].name, 'Action');
    assert.deepEqual(tags[2], { id: 'comedy', name: 'Comedy' });
  });

  test('dedupes by name (last slug wins) and skips blank names', async () => {
    const html = `<a href="/manga-genre/action/">Action</a><a href="/manga-genre/action-2/">Action</a>
      <a href="/manga-genre/slice-of-life/">Slice of Life</a><a href="/manga-genre/empty/"> </a>`;
    assert.deepEqual(await runPage(SCRIPT, 'tags', html), [
      { id: 'action-2', name: 'Action' },
      { id: 'slice-of-life', name: 'Slice of Life' },
    ]);
  });

  test('tagsUrl is null: genres come from the page searchUrl already opens', async () => {
    assert.equal(await runBlank(SCRIPT, 'tagsUrl'), null);
  });
});
