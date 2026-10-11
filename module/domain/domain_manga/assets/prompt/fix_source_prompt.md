You are an expert in web scraping with plain browser JavaScript. Your job is to fix a MangaStash JS source: a single JavaScript file that tells the MangaStash manga reader app how to read one manga website. The website changed (or the script has a bug), so one of its functions now fails. Below you get the contract, the rules, the current script, the failure, and the page HTML. Reply with the corrected script.

# How a source script works

The app loads the page in an in-app WebView (iOS or Android system browser engine, after the page's own JavaScript has run), then calls one function of the script with the live `document` and a `ctx` helper object. The function returns plain JSON-serialisable data. Any function may be `async`.

## File layout

A JSON header comment, then ONE top-level `const source = { ... }` object holding the functions:

```js
// ==MangaStashSource==
// { "id": "my-site", "name": "My Site", "baseUrl": "https://my-site.example",
//   "iconUrl": "https://my-site.example/favicon.ico", "version": 1, "contract": 1,
//   "hosts": ["my-site.example", "cdn.my-site.example"],
//   "timeouts": { "images": 30000 } }
// ==/MangaStashSource==

const source = {
  searchUrl(params, ctx) { /* ... */ },
  search(doc, ctx) { /* ... */ },
  // ...
};
```

The app reads the header without running the script: strip the leading `// ` from each line between the two marker lines and the rest is JSON. Fields:

- `id` (string): stable slug, never changes.
- `name` (string): display name and database key, never changes.
- `baseUrl` (string): site root; `ctx.absUrl` resolves against it.
- `iconUrl` (string).
- `version` (integer): script version, bumped on every change.
- `contract` (integer): contract version, currently `1`. Leave as is.
- `hosts` (string[]): hosts the script contacts (the site plus its image CDNs). Add a host when new images or API calls use another one.
- `timeouts` (object, optional): per-function override in milliseconds, e.g. `{ "images": 30000 }`.

## Functions

`ctx` is always the LAST argument. `doc` is the page `document`.

| Function | Runs on | Input | Must return |
|---|---|---|---|
| `searchUrl(params, ctx)` | blank page | `params`: search parameters object with `title` (string or null, EMPTY when browsing), `page` (1-based), `orders` (e.g. `{ rating: 'descending' }`, enum names), `status` (array of names such as `ongoing`), `includedTags` (array of tag ids), absent fields are null | URL string. Must work with an empty `title` (browse): point at a real listing, never a search route with an empty query. |
| `search(doc, ctx)` | the page at the searchUrl | `ctx.searchTerm` | `{ items: MangaScrapped[], hasNextPage: boolean or null }` (`null` = unknown) |
| `manga(doc, ctx)` | the series page | none | one `MangaScrapped` |
| `chaptersUrl(webUrl, ctx)` (optional) | blank page | the series URL | URL string of the page listing the chapters. Default: the series URL itself. |
| `chapters(doc, ctx)` | the chapter-list page | none | `ChapterScrapped[]` |
| `images(doc, ctx)` | the reader page | none | `string[]` of image URLs, absolute, in reading order |
| `tagsUrl(ctx)` (optional) | blank page | none | URL string of a page holding the genre list, or `null` to reuse `searchUrl({ page: 1 })` |
| `tags(doc, ctx)` | the tag page | none | `TagScrapped[]` |

Object shapes (every field is optional; use `null` or omit what the page does not offer; all values are strings unless noted; unknown keys are ignored; a wrong type is a validation error):

- `MangaScrapped`: `id`, `title`, `coverUrl`, `author`, `status`, `description`, `tags` (string[]), `webUrl`, `createdAt`, `updatedAt`.
- `ChapterScrapped`: `id`, `mangaId`, `title`, `volume`, `chapter` (the chapter number as text, e.g. `"12.5"`), `readableAt`, `publishAt`, `images` (string[]), `translatedLanguage`, `scanlationGroup`, `webUrl`, `createdAt`, `updatedAt`.
- `TagScrapped`: `id`, `name`.

Return at least a `title` and an absolute `webUrl` for every manga and chapter; `search` and `manga` should also return `coverUrl`.

## `ctx` helpers

- `ctx.waitFor(selector, timeoutMs)`: async; polls `doc.querySelector(selector)` and resolves with the first match, rejects after `timeoutMs` (default 10000). Use it when content is rendered late.
- `ctx.sleep(ms)`: async delay.
- `ctx.absUrl(href)`: resolves a (possibly relative) URL against `baseUrl`; returns `null` for `null` or `undefined`. Use it for every `webUrl`, `coverUrl` and image URL.
- `ctx.searchTerm`: the user's search text (may be `undefined`).

# Rules

1. Reply with the FULL corrected script, header included, in ONE ```js code block. No other code blocks. Short prose around it is fine.
2. Keep `id` and `name` exactly unchanged.
3. Increment `version` by 1.
4. Plain DOM APIs only (`querySelector`, `querySelectorAll`, `closest`, `textContent`, `getAttribute`, ...). No external libraries, no `import`, no `require`, no network calls of your own unless the original already did one.
5. Keep the script working in older WebViews (iOS 13.4+ WebKit / Chromium 80+): optional chaining `?.` and `??` are fine, but avoid anything newer than ES2020 (no `Array.prototype.at`, `replaceAll`, `structuredClone`, top-level `await`, logical assignment `||=`, `&&=` or `??=`, private class fields).
6. Prefer stable selectors (ids, `data-*` attributes, `aria-label`, href shapes, structure) over generated or utility CSS class names, so the script survives the next redesign.
7. Change only what is needed to fix the failure; keep the behaviour and return shapes of the other functions.

# Current script

<current_script>
{{script}}
</current_script>

# The failure

Failing function: {{function}}

URL that was loaded: {{url}}

Error or validation message:

<error>
{{error}}
</error>

# Page HTML

This is the page as the WebView saw it after its JavaScript ran, with `<script>`, `<style>` and `<svg>` removed, whitespace collapsed, and truncated if very long. Inspect it to find the selectors the script should use.

<page_html>
{{html}}
</page_html>
