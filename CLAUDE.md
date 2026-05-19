# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TEI Tools: a static, no-build-step browser app with four features:
1. **DOCX → TEI Converter** — sends `.docx` files to the [TEI Garage](https://teigarage.tei-c.org/) REST API and displays the resulting TEI/XML
2. **TEI/XML Viewer** — loads user-edited TEI/XML files for visualization with syntax highlighting and CETEIcean preview
3. **XSL Gallery** — a catalog of downloadable, standalone XSLT 1.0 stylesheets, each paired with a bundled sample; applies a chosen XSL to a sample, an uploaded TEI/XML file, or an uploaded OCR result folder
4. **TEI Gallery** — a two-pane launcher: pick an XML document (left) and an XSL stylesheet (right), then open that combination full-screen in `view.html` (page `publisher.html`; renamed from "TEI Publisher" to avoid clashing with the e-editiones product)

Deployed to GitHub Pages at https://toyo-bunko.github.io/tei-tools/ — published automatically from the `/docs` folder of the `main` branch.

## Development

No build step. Serve the `docs/` directory with any HTTP server:

```bash
cd docs && python3 -m http.server 8000
```

There are no tests or linting configured.

`wrangler` is the only dev dependency (for Cloudflare Pages deployment).

### Regenerating the gallery catalog

`docs/catalog.json` powers the TEI Gallery's document/stylesheet lists. It is
generated — do not hand-edit it. After changing any `docs/xml/*/tei.xml`,
`docs/xsl/*.xsl` header comment, or `docs/xml/sources.json`, rebuild it:

```bash
npm run catalog
```

The script (`scripts/build-catalog.mjs`, dependency-free Node) reads the
teiHeader of each XML and the leading comment of each XSL, fetches remote
documents once, and writes `docs/catalog.json`.

## Architecture

All application code lives in `docs/` — multi-page structure:

### HTML pages
- **`index.html`** — landing page with links to converter, viewer, and XSL gallery
- **`convert.html`** — DOCX → TEI conversion page
- **`viewer.html`** — TEI/XML viewer page
- **`examples.html`** — XSL gallery page
- **`publisher.html`** — TEI Gallery: two-pane XML × XSL launcher
- **`view.html`** — full-screen renderer for `?url=` shareable links (no site chrome)

### JavaScript — `docs/js/`, split into `shared/` and `pages/`

`js/shared/` — code used across pages and reused by XSL outputs:
- **`common.js`** — i18n (`I18N` object, `applyLang()`), the shared `XSL_CATALOG`, `renderChrome()` (injects the shared header/footer/GitHub link), XML formatting/highlighting, CETEIcean preview, tab switching, theme/error helpers
- **`tei-header.js`** — reusable sticky top bar + teiHeader modal. An XSL emits a `<div class="tei-header" data-title="…">` holding `<section class="tei-panel" data-label="…">` blocks (and optional `.tei-extra` buttons); this script builds the bar, the menu, and the modal. Exposes `--tei-bar-h`.
- **`osd-facsimile.js`** — reusable IIIF / image viewer. An XSL emits `<div class="facsimile" data-iiif="…">` with a `<script type="application/json" class="facsimile-zones">` array; this script loads OpenSeadragon from a CDN, mounts a zoom/pan viewer, and overlays the zones. `data-iiif` may be an `info.json` URL (tiled), a plain image URL, or a `blob:` URL. A `[data-zone-toggle]` button toggles overlays. Exposes `window.OSDFacsimile.mount`/`mountWithin` for lazy mounting inside paged views.
- **`tei-pager.js`** — reusable page-by-page navigator. An XSL emits `<div class="tei-pager">` holding `<section class="tei-page">` blocks; this script shows one page at a time with a prev/next bar (←/→ keys), driving visibility via inline `display`, and lazily mounts each page's OpenSeadragon viewers via `OSDFacsimile.mountWithin`. Include it before `osd-facsimile.js`.
- **`osd-sync.js`** — reusable scroll-synced single IIIF viewer. An XSL emits `<div class="osd-sync">` with an `.osd-sync-text` column of `<section class="osd-sync-page" data-iiif="…">` blocks (each holding a `.facsimile-zones` JSON script) and an empty `.osd-sync-view`; this script mounts one OpenSeadragon viewer and, as pages scroll through, `viewer.open()`s the in-view page's image and redraws its zones (via `IntersectionObserver`).

`js/pages/` — per-page logic:
- **`convert.js`** — TEI Garage API call, file upload, sample file handling
- **`viewer.js`** — XML file upload and display
- **`examples.js`** — XSL gallery logic: `XSLTProcessor` transformation, folder ingestion, image-URL resolution, iframe rendering (uses `XSL_CATALOG` from `common.js`)
- **`view.js`** — standalone (no `common.js`) renderer for `view.html`: reads `?url=`/`?xsl=`, transforms, and replaces the document with the result
- **`publisher.js`** — TEI Gallery logic: loads `catalog.json`, merges it with `XSL_CATALOG` routing, renders the XML/XSL panes, opens `view.html?url=…&xsl=…` in a new tab

### Other
- **`style.css`** — all styles including responsive design, CETEIcean element rendering
- **`docx/sample.docx`** — converter sample (not fetched at runtime; the DOCX is Base64-embedded in `convert.js` as `SAMPLE_B64` — this file is the source it was encoded from)
- **`catalog.json`** — generated index of all gallery XML documents and XSL stylesheets (description / language / category / license). Built by `scripts/build-catalog.mjs`; consumed by `publisher.js`. **Do not hand-edit** — run `npm run catalog`.
- **`xml/`** — bundled TEI documents, one folder per project, each holding `tei.xml` (+ assets): `xml/tei-guide/` (TEI/XML encoding guide — the viewer's and reading/notes/bibliography XSLs' shared sample), `xml/ocr-sample/` (`tei.xml` + `images/`, for the OCR facsimile XSL), `xml/vellum/` (a Toyo Bunko Vellum document — its host sends no CORS header, so a copy is bundled). **`xml/sources.json`** — hand-edited manifest listing these bundled documents plus remote ones (the u-renja document, referenced live since its DTS API allows CORS); read by the catalog build script.
- **`xsl/`** — standalone XSLT 1.0 stylesheets (each outputs a complete HTML document). Generic: `tei-reading`, `tei-notes`, `tei-bibliography`, `tei-ocr-facsimile`. Project-specific: `tei-vellum` (Toyo Bunko Vellum contract documents) and `tei-urenja` (Yūrensha / NDL classical-book OCR). Each starts with a structured leading comment (`Title:` / `Description:` / `Category:` / `License:` lines) parsed by the catalog build script. Every XSL emits a shared `.tei-header` block consumed by `js/shared/tei-header.js`. `tei-vellum` (single image) and `tei-ocr-facsimile` (paged: `.tei-pager` + `tei-pager.js`) emit `.facsimile` blocks for `js/shared/osd-facsimile.js`; `tei-urenja` emits an `.osd-sync` two-panel block (vertical scrolling text + one viewer) for `js/shared/osd-sync.js`. The XSL holds only project-specific layout + data; viewer/header/pager behaviour lives in the shared JS.
- **`scripts/build-catalog.mjs`** — dependency-free Node script that generates `docs/catalog.json` (see "Regenerating the gallery catalog" above).

External dependency: [CETEIcean](https://github.com/TEIC/CETEIcean) loaded from CDN in convert.html and viewer.html.

## Key Patterns

- **i18n**: `I18N` object in `common.js` holds all JA/EN strings. HTML elements use `data-i18n="key"` attributes. `applyLang()` updates the DOM.
- **API endpoint**: The TEI Garage conversion URL is hardcoded in `convert.js` as the `API` constant.
- **XML display**: Custom syntax highlighting via regex-based `highlightXml()` in `common.js` (not a library).
- **TEI preview**: CETEIcean transforms TEI XML into custom HTML elements; CSS in `style.css` styles them (`.tei-preview tei-*` selectors).
- **Note popups**: `tei-note` elements show content on hover via pure CSS (`:hover > *`).
- **Shared header/footer**: `renderChrome()` in `common.js` injects the GitHub link, `.site-header` (sticky nav) and `.site-footer` into every page that loads `common.js` — pages no longer carry their own `<header>`/`<footer>` markup, so nav changes are made in exactly one place. The XSL gallery (`examples.html`) nav/landing link is currently commented out there: the file is kept but unlinked, since it overlaps with the TEI Gallery (`publisher.html`). (`view.html` loads `view.js` only and has no chrome.)
- **XSL gallery**: `examples.js` applies an `xsl/*.xsl` stylesheet to TEI/XML with the browser's built-in `XSLTProcessor` (XSLT 1.0 only). Each XSL outputs a full standalone HTML document, rendered inside a sandboxed `<iframe srcdoc>`. Images referenced by `<graphic url="…">` are resolved before transformation: relative to a bundled directory, or to `blob:` URLs built from an uploaded folder.
- **Shareable `?url=` links**: `examples.html?url=…` redirects to `view.html`, which renders the transformation full-screen (via `document.write`). `?url=` is the TEI/XML URL; optional `?xsl=` is a catalog id (`reading`/`notes`/`bibliography`/`ocr`) or an arbitrary XSL URL; omitting `?xsl=` guesses from the markup.
