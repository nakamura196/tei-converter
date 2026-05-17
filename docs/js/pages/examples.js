/* ======== XSL Gallery ========
   A catalog of standalone XSLT 1.0 stylesheets. Each can be downloaded and
   reused as-is; each is paired with a bundled sample. Visitors can also feed
   their own TEI/XML file, an OCR result folder, or a published XML via the
   ?url= query parameter. */

/* A ?url= request is a shareable link to a single rendering — send it to the
   dedicated full-screen renderer (view.html) instead of the gallery. */
if (new URLSearchParams(location.search).get('url')) {
  location.replace('view.html' + location.search);
}

/* XSL_CATALOG is defined in common.js (shared with publisher.js). */

/* ---- State ---- */
let selectedXsl   = XSL_CATALOG[0];
let loadedXmlText = '';
let imageResolver = null;   // (relativeUrl) => resolvable URL, or null
let objectUrls    = [];     // blob: URLs to revoke on the next load

/* ---- Elements ---- */
const catalogEl   = document.getElementById('xslCatalog');
const dropzone    = document.getElementById('xmlDropzone');
const xmlInput    = document.getElementById('xmlFileInput');
const folderBtn   = document.getElementById('folderBtn');
const folderInput = document.getElementById('folderInput');
const fileNameEl  = document.getElementById('xmlFileName');
const result      = document.getElementById('result');
const frame       = document.getElementById('renderFrame');
const appliedEl   = document.getElementById('appliedXsl');
const openTabBtn  = document.getElementById('openTabBtn');

const IMAGE_RE = /\.(png|jpe?g|gif|webp|bmp|tiff?|avif)$/i;

/* ======== Catalog rendering ======== */
function renderCatalog() {
  catalogEl.innerHTML = '';
  XSL_CATALOG.forEach(entry => {
    const card = document.createElement('div');
    card.className = 'xsl-card' + (entry.id === selectedXsl.id ? ' selected' : '');
    card.dataset.id = entry.id;
    const badge = entry.input === 'folder' ? t('exInputFolder') : t('exInputFile');
    card.innerHTML =
      '<div class="xsl-card-head">' +
        '<h3>' + esc(entry.title[lang] || entry.title.ja) + '</h3>' +
        '<span class="xsl-badge">' + esc(badge) + '</span>' +
      '</div>' +
      '<p class="xsl-card-desc">' + esc(entry.desc[lang] || entry.desc.ja) + '</p>' +
      '<div class="xsl-card-actions">' +
        '<button class="btn-primary try-btn">' + esc(t('exTrySample')) + '</button>' +
        '<a class="btn-secondary dl-btn" href="' + entry.xsl + '" download>' +
          esc(t('exDownloadXsl')) + '</a>' +
        '<code class="xsl-path">' + esc(entry.xsl) + '</code>' +
      '</div>';
    card.addEventListener('click', e => {
      if (e.target.closest('.dl-btn')) return;   // let the download link work
      selectXsl(entry.id);
      if (e.target.closest('.try-btn')) loadSample(entry);
    });
    catalogEl.appendChild(card);
  });
}

function selectXsl(id) {
  const entry = XSL_CATALOG.find(x => x.id === id);
  if (!entry) return;
  selectedXsl = entry;
  document.querySelectorAll('.xsl-card').forEach(c =>
    c.classList.toggle('selected', c.dataset.id === id));
  updateAppliedLabel();
}

function updateAppliedLabel() {
  appliedEl.textContent = t('exApplied') + ' ' +
    (selectedXsl.title[lang] || selectedXsl.title.ja);
}

/* ======== Image URL resolution ========
   The XSL output references images via the relative path in <graphic url="…"/>.
   That path must be rewritten to a URL the browser can actually load. */
function revokeObjectUrls() {
  objectUrls.forEach(u => URL.revokeObjectURL(u));
  objectUrls = [];
}
function joinPath(dir, rel) { return dir ? dir + '/' + rel : rel; }
function normalizePath(p) {
  const parts = [];
  p.split('/').forEach(seg => {
    if (seg === '' || seg === '.') return;
    if (seg === '..') parts.pop();
    else parts.push(seg);
  });
  return parts.join('/');
}
// Resolve `rel` against a directory bundled under the site.
function siteDirResolver(dir) {
  return rel => new URL(joinPath(dir, rel), location.href).href;
}
// Resolve `rel` against an uploaded folder: relative path -> blob: URL.
function folderResolver(imageMap, xmlDir) {
  return rel => imageMap[normalizePath(joinPath(xmlDir, rel))] || rel;
}

/* Rewrite every <graphic url="…"> in the parsed TEI document. */
function rewriteGraphicUrls(xmlDoc) {
  if (!imageResolver) return;
  const graphics = xmlDoc.getElementsByTagNameNS('*', 'graphic');
  for (let i = 0; i < graphics.length; i++) {
    const u = graphics[i].getAttribute('url');
    if (u) graphics[i].setAttribute('url', imageResolver(u));
  }
}

/* ======== Core transform ======== */
async function runTransform() {
  if (!loadedXmlText || !selectedXsl) return;
  hideError();
  try {
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(loadedXmlText, 'application/xml');
    if (xmlDoc.querySelector('parsererror')) throw new Error(t('errXmlParse'));
    rewriteGraphicUrls(xmlDoc);

    const xslRes = await fetch(selectedXsl.xsl);
    if (!xslRes.ok) throw new Error(t('errXsl'));
    const xslDoc = parser.parseFromString(await xslRes.text(), 'application/xml');
    if (xslDoc.querySelector('parsererror')) throw new Error(t('errXsl'));

    const proc = new XSLTProcessor();
    proc.importStylesheet(xslDoc);
    const outDoc = proc.transformToDocument(xmlDoc);
    if (!outDoc || !outDoc.documentElement) throw new Error(t('errXsl'));

    // documentElement.outerHTML gives a proper HTML serialization
    // (void elements, no XHTML quirks); prepend the doctype ourselves.
    const html = '<!DOCTYPE html>\n' + outDoc.documentElement.outerHTML;
    showResult(html);
  } catch (err) {
    console.error('Transform failed:', err);
    showError(String(err && err.message ? err.message : err));
  }
}

function showResult(html) {
  frame.srcdoc = html;
  // Back the "open in new tab" link with a blob URL of the same output.
  const blobUrl = URL.createObjectURL(new Blob([html], { type: 'text/html' }));
  objectUrls.push(blobUrl);
  openTabBtn.href = blobUrl;
  result.classList.add('active');
  updateAppliedLabel();
  result.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Resize the iframe to fit its content once everything has loaded.
frame.addEventListener('load', () => {
  try {
    const doc = frame.contentDocument;
    if (!doc) return;
    const h = Math.max(doc.documentElement.scrollHeight, doc.body.scrollHeight);
    if (h > 0) frame.style.height = (h + 8) + 'px';
  } catch (e) { /* leave the default height */ }
});

/* ======== Loading inputs ======== */
function resetInput() {
  revokeObjectUrls();
  imageResolver = null;
  loadedXmlText = '';
}

async function loadSample(entry) {
  resetInput();
  try {
    if (entry.sample.kind === 'file') {
      loadedXmlText = await (await fetch(entry.sample.path)).text();
      imageResolver = null;
    } else {
      const dir = entry.sample.dir;
      loadedXmlText = await (await fetch(joinPath(dir, entry.sample.xml))).text();
      imageResolver = siteDirResolver(dir);
    }
    fileNameEl.textContent = (lang === 'ja' ? 'サンプル: ' : 'Sample: ') +
      (entry.title[lang] || entry.title.ja);
    dropzone.classList.add('has-file');
    await runTransform();
  } catch (err) {
    showError(t('errSample'));
  }
}

function loadSingleXmlFile(file) {
  resetInput();
  const reader = new FileReader();
  reader.onload = e => {
    loadedXmlText = e.target.result;
    imageResolver = null;
    fileNameEl.textContent = file.name + ' (' + formatSize(file.size) + ')';
    dropzone.classList.add('has-file');
    runTransform();
  };
  reader.readAsText(file);
}

/* Ingest an uploaded folder. `items` is [{ relPath, file }]. */
async function ingestFolder(items) {
  resetInput();
  if (!items.length) return;
  // Strip the top-level folder name so paths match the TEI's relative URLs.
  const topDir = items[0].relPath.split('/')[0];
  const stripped = items.map(it => {
    const parts = it.relPath.split('/');
    return { path: parts.length > 1 ? parts.slice(1).join('/') : it.relPath, file: it.file };
  });
  // Pick the TEI/XML file: prefer tei.xml, otherwise the first *.xml.
  const xmls = stripped.filter(it => /\.xml$/i.test(it.path));
  const xmlItem = xmls.find(it => /(^|\/)tei\.xml$/i.test(it.path)) || xmls[0];
  if (!xmlItem) { showError(t('errFolderNoXml')); return; }

  const imageMap = {};
  stripped.forEach(it => {
    if (IMAGE_RE.test(it.path)) {
      const url = URL.createObjectURL(it.file);
      objectUrls.push(url);
      imageMap[normalizePath(it.path)] = url;
    }
  });
  const xmlDir = xmlItem.path.split('/').slice(0, -1).join('/');
  loadedXmlText = await xmlItem.file.text();
  imageResolver = folderResolver(imageMap, xmlDir);
  fileNameEl.textContent = topDir + '/  (' + xmls.length + ' XML, ' +
    Object.keys(imageMap).length + ' images)';
  dropzone.classList.add('has-file');
  // A folder of page images is an OCR result — switch to the OCR view.
  if (selectedXsl.input !== 'folder') selectXsl('ocr');
  await runTransform();
}

/* ======== Drag & drop / file pickers ======== */
dropzone.addEventListener('click', () => xmlInput.click());

xmlInput.addEventListener('change', () => {
  if (xmlInput.files[0]) loadSingleXmlFile(xmlInput.files[0]);
  xmlInput.value = '';
});

folderBtn.addEventListener('click', () => folderInput.click());
folderInput.addEventListener('change', () => {
  const files = Array.from(folderInput.files || []);
  if (files.length) {
    ingestFolder(files.map(f => ({ relPath: f.webkitRelativePath || f.name, file: f })));
  }
  folderInput.value = '';
});

dropzone.addEventListener('dragover', e => {
  e.preventDefault();
  dropzone.classList.add('dragover');
});
dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
dropzone.addEventListener('drop', async e => {
  e.preventDefault();
  dropzone.classList.remove('dragover');
  const dt = e.dataTransfer;
  // Detect a dropped directory via the Entries API.
  const entries = [];
  if (dt.items) {
    for (const item of dt.items) {
      const entry = item.webkitGetAsEntry && item.webkitGetAsEntry();
      if (entry) entries.push(entry);
    }
  }
  const dirEntry = entries.find(en => en && en.isDirectory);
  if (dirEntry) {
    const collected = [];
    await traverseEntry(dirEntry, '', collected);
    ingestFolder(collected);
    return;
  }
  const file = dt.files && dt.files[0];
  if (file) loadSingleXmlFile(file);
});

function readEntries(reader) {
  return new Promise((res, rej) => reader.readEntries(res, rej));
}
async function traverseEntry(entry, prefix, out) {
  if (entry.isFile) {
    const file = await new Promise((res, rej) => entry.file(res, rej));
    out.push({ relPath: prefix + entry.name, file });
  } else if (entry.isDirectory) {
    const reader = entry.createReader();
    let batch;
    do {
      batch = await readEntries(reader);
      for (const child of batch) {
        await traverseEntry(child, prefix + entry.name + '/', out);
      }
    } while (batch.length > 0);
  }
}

/* ======== Init ======== */
renderCatalog();
updateAppliedLabel();
// Re-render catalog labels after the language toggle in common.js.
document.getElementById('langBtn').addEventListener('click', () => {
  renderCatalog();
  updateAppliedLabel();
});
