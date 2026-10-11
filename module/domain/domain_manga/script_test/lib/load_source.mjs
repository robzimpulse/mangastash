/**
 * Node test harness for MangaStash JS source scripts.
 *
 * Purpose: loads a script from ../../assets/sources/<file> the same way the app
 * runtime does, so scripts can be unit-tested against saved HTML fixtures.
 *   - the header is parsed with the SAME grammar as Dart's SourceScript.parse
 *     (module/library/entity_manga_external/lib/src/source_script.dart):
 *     `// ==MangaStashSource==` ... `// ==/MangaStashSource==`, inner lines
 *     stripped of `//` + one optional space, joined, parsed as a JSON object;
 *   - the shared ctx helpers come from core_network/assets/source_ctx.js
 *     (the very file the app injects);
 *   - the script body is evaluated by indirect eval with
 *     `\n;source;\n//# sourceURL=mangastash-source.js` appended, so the
 *     `const source = {...}` object is the completion value.
 *
 * Exports:
 *   loadSource(path)                       -> { meta, source }
 *   runPage(path, fn, html, { searchTerm, waitTimeoutMs }) -> Promise<result>
 *       calls source[fn](doc, ctx) with doc = linkedom parseHTML(html).document;
 *       waitTimeoutMs, when given, replaces EVERY ctx.waitFor timeout
 *   runBlank(path, fn, ...args)            -> Promise<result>
 *       calls source[fn](...args, ctx) on an empty document (URL functions)
 * `path` may be a bare file name (resolved under assets/sources) or a path.
 * Results are JSON round-tripped, exactly like the app's JS bridge does.
 *
 * Use: `import { runPage } from './lib/load_source.mjs'` in *.test.mjs files;
 * run with `npm test` from script_test/.
 */
import { readFileSync } from 'node:fs';
import { isAbsolute, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseHTML } from 'linkedom';

const here = fileURLToPath(new URL('.', import.meta.url));
const SOURCES_DIR = resolve(here, '../../assets/sources');
const CTX_PATH = resolve(here, '../../../../core/core_network/assets/source_ctx.js');

const OPEN = '// ==MangaStashSource==';
const CLOSE = '// ==/MangaStashSource==';
const SLUG = /^[a-z0-9]+(-[a-z0-9]+)*$/;

function resolveScriptPath(path) {
  return isAbsolute(path) || path.includes('/') ? resolve(path) : resolve(SOURCES_DIR, path);
}

/** Parses the metadata header; throws Error with a human readable message. */
export function parseHeader(code) {
  const lines = code.replace(/^[﻿\s]+/, '').split(/\r\n|\r|\n/);
  if (lines[0].trimEnd() !== OPEN) {
    throw new Error('Script must start with "// ==MangaStashSource==" header');
  }
  const inner = [];
  let closed = false;
  for (const line of lines.slice(1)) {
    const trimmed = line.trimEnd();
    if (trimmed === CLOSE) {
      closed = true;
      break;
    }
    if (!trimmed.startsWith('//')) {
      throw new Error('Every header line must start with "//"');
    }
    const body = trimmed.slice(2);
    inner.push(body.startsWith(' ') ? body.slice(1) : body);
  }
  if (!closed) {
    throw new Error('Header is missing the closing "// ==/MangaStashSource==" line');
  }
  let meta;
  try {
    meta = JSON.parse(inner.join('\n'));
  } catch (e) {
    throw new Error(`Header is not valid JSON: ${e.message}`);
  }
  if (meta === null || typeof meta !== 'object' || Array.isArray(meta)) {
    throw new Error('Header JSON must be an object');
  }
  for (const key of ['id', 'name', 'baseUrl']) {
    if (typeof meta[key] !== 'string' || meta[key].trim() === '') {
      throw new Error(`"${key}" is required and must be a string`);
    }
  }
  if (!SLUG.test(meta.id)) throw new Error(`"id" must be a lowercase slug, got "${meta.id}"`);
  for (const key of ['version', 'contract']) {
    if (!Number.isInteger(meta[key]) || meta[key] < 1) {
      throw new Error(`"${key}" is required and must be an integer >= 1`);
    }
  }
  if (!Array.isArray(meta.hosts) || meta.hosts.length === 0) {
    throw new Error('"hosts" is required and must be a non-empty list');
  }
  return meta;
}

function loadCreateCtx() {
  // Indirect eval: the function declaration is evaluated in global scope; the
  // trailing expression is the completion value.
  return (0, eval)(`${readFileSync(CTX_PATH, 'utf8')}\n;createSourceCtx;`);
}

/** Loads a source script: `{ meta, source, createSourceCtx }`. */
export function loadSource(path) {
  const code = readFileSync(resolveScriptPath(path), 'utf8');
  const meta = parseHeader(code);
  const source = (0, eval)(`${code}\n;source;\n//# sourceURL=mangastash-source.js`);
  return { meta, source, createSourceCtx: loadCreateCtx() };
}

// What crosses the app's JS bridge is JSON; mirror that so tests see the same
// shape (undefined fields dropped, plain prototypes).
const bridge = (value) => (value === undefined ? undefined : JSON.parse(JSON.stringify(value)));

function callFunction(source, fn, args) {
  if (typeof source[fn] !== 'function') {
    throw new Error(`source.${fn} is not a function`);
  }
  return source[fn](...args);
}

/** Runs a page function: `source[fn](doc, ctx)` against the given HTML. */
export async function runPage(path, fn, html, { searchTerm, waitTimeoutMs } = {}) {
  const { meta, source, createSourceCtx } = loadSource(path);
  const doc = parseHTML(html).document;
  const ctx = createSourceCtx({ doc, baseUrl: meta.baseUrl, searchTerm });
  if (waitTimeoutMs !== undefined) {
    const waitFor = ctx.waitFor;
    // waitTimeoutMs wins over an explicit per-call timeout too (scripts pass
    // the production timeouts, e.g. 30000, which would make timeout tests crawl).
    ctx.waitFor = (selector) => waitFor(selector, waitTimeoutMs);
  }
  return bridge(await callFunction(source, fn, [doc, ctx]));
}

/**
 * Runs a page function with a ctx whose `waitFor` records its arguments and
 * resolves immediately, and returns the recorded `[selector, timeoutMs]`
 * pairs. Pins the readiness budgets a script passes (master waited within the
 * hook timeouts, not the 10 s ctx default). A throw after the wait (nothing
 * to parse in the given HTML) is ignored.
 */
export async function recordWaitFor(path, fn, html = '<html><body></body></html>') {
  const { meta, source, createSourceCtx } = loadSource(path);
  const doc = parseHTML(html).document;
  const ctx = createSourceCtx({ doc, baseUrl: meta.baseUrl });
  const calls = [];
  ctx.waitFor = async (selector, timeoutMs) => {
    calls.push([selector, timeoutMs]);
    return null;
  };
  try {
    await callFunction(source, fn, [doc, ctx]);
  } catch {
    // only the recorded waits matter
  }
  return calls;
}

/** Runs a blank-page (URL) function: `source[fn](...args, ctx)`. */
export async function runBlank(path, fn, ...args) {
  const { meta, source, createSourceCtx } = loadSource(path);
  const doc = parseHTML('<html><head></head><body></body></html>').document;
  const ctx = createSourceCtx({ doc, baseUrl: meta.baseUrl });
  return bridge(await callFunction(source, fn, [...args, ctx]));
}
