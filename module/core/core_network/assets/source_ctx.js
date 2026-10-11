/**
 * Shared `ctx` helpers handed to every MangaStash JS source function.
 *
 * Purpose: defines the global function `createSourceCtx({ doc, baseUrl,
 * searchTerm })`, which returns the tiny helper object a source script receives
 * as its LAST argument:
 *   - sleep(ms)                -> Promise resolved after `ms` milliseconds.
 *   - waitFor(selector, ms)    -> polls `doc.querySelector(selector)` every
 *                                 100 ms; resolves with the first match or
 *                                 rejects Error('waitFor timed out: <selector>')
 *                                 after `ms` (default 10000).
 *   - absUrl(href)             -> `href` resolved against `baseUrl`; null for
 *                                 null/undefined input.
 *   - searchTerm               -> the user's search text (may be undefined).
 *
 * Errors these helpers raise carry `fromHarness = true`: the harness then posts
 * no `line`/`column` for them (iOS would report a position inside this file).
 *
 * How to use: the Dart runtime (core_network) loads this file as an asset and
 * evaluates it before the source script inside the webview; the Node test
 * harness (domain_manga/script_test/lib/load_source.mjs) evaluates the very
 * same file, so the helpers behave identically in tests. Plain ES2017, no
 * dependencies, no module syntax - it must stay evaluable via `eval`.
 */
function createSourceCtx({ doc, baseUrl, searchTerm }) {
  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  const waitFor = async (selector, timeoutMs = 10000) => {
    const deadline = Date.now() + timeoutMs;
    for (;;) {
      const found = doc.querySelector(selector);
      if (found) return found;
      if (Date.now() >= deadline) {
        const timeout = new Error('waitFor timed out: ' + selector);
        timeout.fromHarness = true;
        throw timeout;
      }
      await sleep(100);
    }
  };

  const absUrl = (href) => {
    if (href === null || href === undefined) return null;
    try {
      return new URL(href, baseUrl).href;
    } catch (err) {
      // Raised here, not in the script: no script line applies (see the
      // harness, which skips line/column for errors flagged fromHarness).
      if (err && typeof err === 'object') err.fromHarness = true;
      throw err;
    }
  };

  return { sleep, waitFor, absUrl, searchTerm };
}
