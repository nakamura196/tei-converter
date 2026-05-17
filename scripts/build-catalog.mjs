#!/usr/bin/env node
/* ===================================================================
 * build-catalog.mjs — generate docs/catalog.json for the TEI Gallery.
 *
 * The TEI Gallery (publisher.html) lists XML documents and XSL
 * stylesheets with their description / language / category / license.
 * Rather than hand-maintaining that metadata in JavaScript, this script
 * derives it from the files themselves:
 *
 *   - XML  : the teiHeader of each docs/xml/<id>/tei.xml
 *            (and remote documents listed in docs/xml/sources.json,
 *             fetched once here so the browser never pays CORS/latency)
 *   - XSL  : the structured leading comment of each docs/xsl/*.xsl
 *            (Title: / Description: / Category: / License: lines)
 *
 * Output: docs/catalog.json (committed; the browser just loads it).
 *
 * Run:  npm run catalog      (or: node scripts/build-catalog.mjs)
 *
 * Dependency-free by design: it only extracts a handful of known
 * elements from our own well-formed files, so targeted regex is enough
 * and the project keeps zero runtime/parse dependencies.
 * =================================================================== */

import { readFile, writeFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const DOCS = join(ROOT, 'docs');

/* ---- tiny text helpers ------------------------------------------- */

function decodeEntities(s) {
  return s.replace(/&lt;/g, '<').replace(/&gt;/g, '>')
          .replace(/&quot;/g, '"').replace(/&#39;/g, "'")
          .replace(/&amp;/g, '&');
}
/* Drop tags, collapse whitespace — turns an element's inner XML into
 * a plain one-line string. */
function plain(xml) {
  return decodeEntities(String(xml).replace(/<[^>]+>/g, ' '))
    .replace(/\s+/g, ' ').trim();
}
/* Inner content of the first <name>…</name> (namespace-prefix agnostic). */
function block(xml, name) {
  const m = xml.match(new RegExp(
    `<(?:[\\w.-]+:)?${name}(?:\\s[^>]*)?>([\\s\\S]*?)</(?:[\\w.-]+:)?${name}>`, 'i'));
  return m ? m[1] : null;
}
/* Value of `attr` on the first <name …> tag. */
function attr(xml, name, a) {
  const m = xml.match(new RegExp(
    `<(?:[\\w.-]+:)?${name}\\s[^>]*\\b${a}\\s*=\\s*["']([^"']+)["']`, 'i'));
  return m ? m[1] : null;
}

/* ---- TEI teiHeader extraction ------------------------------------ */

function teiTitle(header) {
  const ts = block(header, 'titleStmt') || header;
  const re = /<(?:[\w.-]+:)?title(\s[^>]*)?>([\s\S]*?)<\/(?:[\w.-]+:)?title>/gi;
  let m;
  while ((m = re.exec(ts))) {
    if (/\btype\s*=/.test(m[1] || '')) continue;   // skip <title type="sub">
    const t = plain(m[2]);
    if (t) return t;
  }
  return '';
}
function teiAbstract(header) {
  const a = block(header, 'abstract');
  if (a) return plain(a);
  const summary = block(header, 'summary');           // msDesc/summary fallback
  if (summary) return plain(summary);
  return '';
}
function teiLanguages(header) {
  const out = [];
  const re = /<(?:[\w.-]+:)?language\s[^>]*\bident\s*=\s*["']([^"']+)["']/gi;
  let m;
  while ((m = re.exec(header))) out.push(m[1]);
  if (!out.length) {
    const ml = attr(header, 'textLang', 'mainLang');
    if (ml) out.push(ml);
  }
  return [...new Set(out)];
}
function teiCategory(header) {
  const tc = block(header, 'textClass') || header;
  const t = block(tc, 'term');
  return t ? plain(t) : '';
}
function teiLicense(header) {
  const av = block(header, 'availability');
  if (av) {
    const lic = block(av, 'licence') || block(av, 'license');
    if (lic) return plain(lic);
    if (block(av, 'p')) return plain(block(av, 'p'));
  }
  return attr(header, 'availability', 'status') || '';
}
function xmlMeta(xmlText) {
  const header = block(xmlText, 'teiHeader') || xmlText;
  return {
    title:       teiTitle(header),
    description: teiAbstract(header),
    languages:   teiLanguages(header),
    category:    teiCategory(header),
    license:     teiLicense(header),
  };
}

/* ---- XSL leading-comment extraction ------------------------------ */

function xslMeta(xslText) {
  const cm = xslText.match(/<!--([\s\S]*?)-->/);
  const c = cm ? cm[1] : '';
  const field = (name) => {
    const m = c.match(new RegExp('^\\s*' + name + ':\\s*(.+?)\\s*$', 'm'));
    return m ? m[1] : '';
  };
  return {
    title:       field('Title'),
    description: field('Description'),
    category:    field('Category'),
    license:     field('License'),
  };
}

/* Drop keys whose value is empty ('' or []) — used so that metadata a
 * remote TEI omits (abstract / textClass / availability are rare in
 * OCR output) falls through to the hand-written fallback. */
function stripEmpty(o) {
  return Object.fromEntries(Object.entries(o).filter(
    ([, v]) => !(v === '' || (Array.isArray(v) && v.length === 0))));
}

/* ---- remote fetch (with timeout + graceful fallback) ------------- */

async function fetchText(url, ms = 20000) {
  const ac = new AbortController();
  const timer = setTimeout(() => ac.abort(), ms);
  try {
    const res = await fetch(url, { signal: ac.signal });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    return await res.text();
  } finally {
    clearTimeout(timer);
  }
}

/* ---- main -------------------------------------------------------- */

async function build() {
  const sources = JSON.parse(
    await readFile(join(DOCS, 'xml', 'sources.json'), 'utf8'));

  /* --- XML documents --- */
  const xml = [];
  for (const entry of sources.xml) {
    let meta;
    if (entry.scope === 'remote') {
      try {
        // Fetched metadata wins where present; the fallback fills any
        // field the remote TEI omits (and is used wholesale on error).
        meta = { ...entry.fallback, ...stripEmpty(xmlMeta(await fetchText(entry.url))) };
        console.log(`  remote ok   ${entry.id}`);
      } catch (err) {
        meta = { ...entry.fallback };
        console.warn(`  remote FAIL ${entry.id} (${err.message}) — using fallback`);
      }
      xml.push({ id: entry.id, scope: 'remote', url: entry.url, ...meta });
    } else {
      meta = xmlMeta(await readFile(join(DOCS, entry.path), 'utf8'));
      console.log(`  bundled     ${entry.id}`);
      xml.push({ id: entry.id, scope: 'bundled', url: entry.path, ...meta });
    }
  }

  /* --- XSL stylesheets --- */
  const xsl = [];
  const xslDir = join(DOCS, 'xsl');
  for (const file of (await readdir(xslDir)).filter(f => f.endsWith('.xsl')).sort()) {
    const meta = xslMeta(await readFile(join(xslDir, file), 'utf8'));
    xsl.push({ url: 'xsl/' + file, ...meta });
    console.log(`  xsl         ${file}`);
  }

  const catalog = { generated: new Date().toISOString(), xml, xsl };
  await writeFile(join(DOCS, 'catalog.json'),
    JSON.stringify(catalog, null, 2) + '\n');
  console.log(`\ncatalog.json written: ${xml.length} XML, ${xsl.length} XSL.`);
}

build().catch(err => { console.error(err); process.exitCode = 1; });
