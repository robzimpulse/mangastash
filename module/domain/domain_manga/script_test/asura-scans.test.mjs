/**
 * Behavioural-parity tests for the Asura Scans JS source script
 * (../assets/sources/asura-scans.js). Every case mirrors one expectation of the
 * Dart test ../test/asura_scan_source_external_test.dart with the SAME expected
 * values, using fixtures ported verbatim to ./fixtures/asura-scans.
 *
 * How to run: `cd module/domain/domain_manga/script_test && npm ci && npm test`.
 */
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { loadSource, recordWaitFor, runBlank, runPage } from './lib/load_source.mjs';

const SCRIPT = 'asura-scans.js';
const fixture = (name) =>
  readFileSync(
    fileURLToPath(new URL(`./fixtures/asura-scans/${name}.html`, import.meta.url)),
    'utf8',
  );
const page = (fn, name, opts) => runPage(SCRIPT, fn, fixture(name), opts);

const COVER =
  'https://cdn.asurascans.com/asura-images/covers/solo-swordmaster.467196-400.webp';

describe('identity', () => {
  test('header meta', () => {
    const { meta, source } = loadSource(SCRIPT);
    assert.equal(meta.id, 'asura-scans');
    assert.equal(meta.name, 'Asura Scans');
    assert.equal(meta.baseUrl, 'https://asurascans.com');
    assert.equal(meta.iconUrl, 'https://asurascans.com/images/logo.webp');
    assert.equal(meta.version, 1);
    assert.equal(meta.contract, 1);
    assert.deepEqual(meta.hosts, ['asurascans.com', 'cdn.asurascans.com']);
    assert.deepEqual(meta.timeouts, { manga: 20000, tags: 20000, images: 30000 });
    for (const fn of ['searchUrl', 'search', 'manga', 'chapters', 'images', 'tags']) {
      assert.equal(typeof source[fn], 'function', fn);
    }
  });
});

describe('reader', () => {
  test('parses all page images in order', async () => {
    const images = await page('images', 'reader');
    assert.equal(images.length, 3);
    assert.deepEqual(images, [
      'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/001.webp?v=1770499638',
      'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/002.webp?v=1770499638',
      'https://cdn.asurascans.com/asura-images/chapters/ending-maker/1/003.webp?v=1770499638',
    ]);
  });

  test('rejects with waitFor timeout when the reader never appears', async () => {
    // Same selector the Dart source declared in readyWhenSelectors.
    await assert.rejects(
      runPage(SCRIPT, 'images', '<html><body></body></html>', { waitTimeoutMs: 150 }),
      /waitFor timed out: div\.select-none img\[data-page-index\]/,
    );
  });
});

describe('browse cards (Astro rebuild, captured live 2026-10)', () => {
  test('search parses div.series-card cards', async () => {
    const { items } = await page('search', 'browse');
    assert.equal(items.length, 1);
    assert.equal(items[0].title, 'Solo Swordmaster');
    assert.equal(
      items[0].webUrl,
      'https://asurascans.com/comics/solo-swordmaster-3ec3b16f',
    );
    assert.equal(items[0].coverUrl, COVER);
    assert.equal(items[0].status, 'ongoing');
  });

  test('search parses cards without the div.p-3 wrapper', async () => {
    const { items } = await page('search', 'browse-redesigned');
    assert.equal(items.length, 2);
    assert.equal(items[0].title, 'Solo Swordmaster');
    assert.equal(
      items[0].webUrl,
      'https://asurascans.com/comics/solo-swordmaster-3ec3b16f',
    );
    assert.equal(items[1].title, 'Bare Title');
    assert.equal(items[1].webUrl, 'https://asurascans.com/comics/bare-title-77');
  });

  test('hasNextPage true while the next-page button is enabled', async () => {
    const { hasNextPage } = await page('search', 'browse');
    assert.equal(hasNextPage, true);
  });

  test('hasNextPage false when the next-page button is disabled', async () => {
    const { hasNextPage } = await page('search', 'browse-last-page');
    assert.equal(hasNextPage, false);
  });
});

describe('series detail (Astro rebuild, captured live 2026-10)', () => {
  test('parses title, cover, description, status, author and genres', async () => {
    const manga = await page('manga', 'detail');
    assert.equal(manga.title, 'Solo Swordmaster');
    assert.equal(manga.coverUrl, COVER);
    assert.ok(manga.description.includes('Limón Asphelder'));
    assert.equal(manga.status, 'ongoing');
    assert.equal(manga.author, 'Shadowless');
    assert.deepEqual(manga.tags, ['Action', 'Adventure', 'Fantasy']);
  });

  test('falls back to the og:image meta when the mobile cover id is gone', async () => {
    const manga = await page('manga', 'detail-no-mobile-cover');
    assert.equal(manga.coverUrl, COVER);
  });
});

describe('chapter list (Astro SSR fallback rows)', () => {
  test('parses chapter rows anchored on the /chapter/{slug} href', async () => {
    const chapters = await page('chapters', 'chapter-list');
    assert.equal(chapters.length, 2);
    assert.equal(chapters[0].title, 'Chapter 10');
    assert.equal(chapters[0].chapter, '10');
    assert.equal(
      chapters[0].webUrl,
      'https://asurascans.com/comics/solo-swordmaster-3ec3b16f/chapter/10',
    );
    assert.equal(chapters[0].readableAt, 'Just now');
    assert.equal(chapters[0].scanlationGroup, 'Asura Scans');
  });

  test('scopes to the chapter-list island and dedupes hero/related rows', async () => {
    const chapters = await page('chapters', 'chapter-scoping');
    assert.equal(chapters.length, 2);
    assert.deepEqual(
      chapters.map((c) => c.title),
      ['Chapter 10', 'Chapter 9'],
    );
    assert.deepEqual(
      chapters.map((c) => c.webUrl),
      [
        'https://asurascans.com/comics/solo-swordmaster-3ec3b16f/chapter/10',
        'https://asurascans.com/comics/solo-swordmaster-3ec3b16f/chapter/9',
      ],
    );
  });
});

describe('tags (astro-island props)', () => {
  test('parses availableGenres from the island props without any script', async () => {
    const tags = await page('tags', 'genres-island');
    assert.equal(tags.length, 3);
    assert.deepEqual(
      tags.map((t) => t.name),
      ['Action', 'Adventure', 'Fantasy'],
    );
    assert.deepEqual(
      tags.map((t) => t.id),
      ['action', 'adventure', 'fantasy'],
    );
  });

  test('degrades malformed props JSON to an empty list', async () => {
    assert.deepEqual(await page('tags', 'genres-broken-props'), []);
  });

  test('degrades a non-list genre payload to an empty list', async () => {
    assert.deepEqual(await page('tags', 'genres-flat-props'), []);
  });

  test('tagsUrl is null: genres live on the search page already opened', async () => {
    assert.equal(await runBlank(SCRIPT, 'tagsUrl'), null);
  });
});

describe('searchUrl', () => {
  // SearchMangaParameter.toJson() encodes enums by NAME (orders: {title:
  // 'ascending'}), see search_manga_parameter.g.dart; page defaults to 1.
  test('title, page and genres match the Dart url()', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', {
        title: 'solo leveling',
        page: 2,
        includedTags: ['action', 'fantasy'],
      }),
      'https://asurascans.com/browse?q=solo leveling&page=2&genres=action,fantasy',
    );
  });

  test('empty title browses with an empty q', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', { page: 1 }),
      'https://asurascans.com/browse?q=&page=1',
    );
  });

  test('order mapping: title, relevance, rating add sort; others only order', async () => {
    const url = (orders) => runBlank(SCRIPT, 'searchUrl', { page: 1, orders });
    assert.equal(
      await url({ title: 'ascending' }),
      'https://asurascans.com/browse?q=&page=1&sort=name&order=asc',
    );
    assert.equal(
      await url({ relevance: 'descending' }),
      'https://asurascans.com/browse?q=&page=1&sort=popular&order=desc',
    );
    assert.equal(
      await url({ rating: 'descending' }),
      'https://asurascans.com/browse?q=&page=1&sort=rating&order=desc',
    );
    assert.equal(
      await url({ latestUploadedChapter: 'descending' }),
      'https://asurascans.com/browse?q=&page=1&order=desc',
    );
  });

  test('status is comma joined; empty lists are omitted', async () => {
    assert.equal(
      await runBlank(SCRIPT, 'searchUrl', {
        page: 3,
        status: ['ongoing', 'completed'],
        includedTags: [],
      }),
      'https://asurascans.com/browse?q=&page=3&status=ongoing,completed',
    );
  });
});

describe('readiness budgets', () => {
  // Master waited for the readiness selector within the hook timeout; the 10 s
  // ctx default would fail slow chapter/genre pages earlier than before.
  test('images waits up to the header timeouts.images', async () => {
    const { meta } = loadSource(SCRIPT);
    const calls = await recordWaitFor(SCRIPT, 'images');
    assert.deepEqual(calls, [['div.select-none img[data-page-index]', meta.timeouts.images]]);
    assert.equal(meta.timeouts.images, 30000);
  });

  test('tags waits up to the header timeouts.tags', async () => {
    const { meta } = loadSource(SCRIPT);
    const calls = await recordWaitFor(SCRIPT, 'tags');
    assert.deepEqual(calls, [['astro-island[props*="availableGenres"]', meta.timeouts.tags]]);
    assert.equal(meta.timeouts.tags, 20000);
  });
});
