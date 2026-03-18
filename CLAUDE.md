# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TEI Tools: a static, no-build-step browser app with two features:
1. **DOCX → TEI Converter** — sends `.docx` files to the [TEI Garage](https://teigarage.tei-c.org/) REST API and displays the resulting TEI/XML
2. **TEI/XML Viewer** — loads user-edited TEI/XML files for visualization with syntax highlighting and CETEIcean preview

Deployed to Cloudflare Pages at https://tei-converter.pages.dev/.

## Development

No build step. Serve the `docs/` directory with any HTTP server:

```bash
cd docs && python3 -m http.server 8000
```

There are no tests or linting configured.

`wrangler` is the only dev dependency (for Cloudflare Pages deployment).

## Architecture

All application code lives in `docs/` — multi-page structure:

### HTML pages
- **`index.html`** — landing page with links to converter and viewer
- **`convert.html`** — DOCX → TEI conversion page
- **`viewer.html`** — TEI/XML viewer page

### JavaScript
- **`common.js`** — shared code: i18n (`I18N` object, `applyLang()`), XML formatting/highlighting, CETEIcean preview, tab switching, error helpers
- **`convert.js`** — converter-specific logic: TEI Garage API call, file upload, sample file handling
- **`viewer.js`** — viewer-specific logic: XML file upload and display

### Other
- **`style.css`** — all styles including responsive design, CETEIcean element rendering
- **`sample.docx`** — bundled sample file for quick testing

External dependency: [CETEIcean](https://github.com/TEIC/CETEIcean) loaded from CDN in convert.html and viewer.html.

## Key Patterns

- **i18n**: `I18N` object in `common.js` holds all JA/EN strings. HTML elements use `data-i18n="key"` attributes. `applyLang()` updates the DOM.
- **API endpoint**: The TEI Garage conversion URL is hardcoded in `convert.js` as the `API` constant.
- **XML display**: Custom syntax highlighting via regex-based `highlightXml()` in `common.js` (not a library).
- **TEI preview**: CETEIcean transforms TEI XML into custom HTML elements; CSS in `style.css` styles them (`.tei-preview tei-*` selectors).
- **Note popups**: `tei-note` elements show content on hover via pure CSS (`:hover > *`).
- **Shared header/footer**: All pages use `.site-header` / `.site-footer` with sticky header. Sub-pages have a `← トップへ` back link.
