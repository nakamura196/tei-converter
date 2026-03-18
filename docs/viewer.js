/* ======== TEI/XML Viewer ======== */
const xmlDropzone   = document.getElementById('xmlDropzone');
const xmlFileInput  = document.getElementById('xmlFileInput');
const xmlFileName   = document.getElementById('xmlFileName');
const result        = document.getElementById('result');
const xmlPreview    = document.getElementById('xmlPreview');
const copyBtn       = document.getElementById('copyBtn');
const downloadBtn   = document.getElementById('downloadBtn');
let resultXml = '';

/* ======== Drag/drop and file selection ======== */
xmlDropzone.addEventListener('click', () => xmlFileInput.click());

xmlDropzone.addEventListener('dragover', e => {
  e.preventDefault();
  xmlDropzone.classList.add('dragover');
});

xmlDropzone.addEventListener('dragleave', () => xmlDropzone.classList.remove('dragover'));

xmlDropzone.addEventListener('drop', e => {
  e.preventDefault();
  xmlDropzone.classList.remove('dragover');
  const file = e.dataTransfer.files[0];
  if (file) loadXmlFile(file);
});

xmlFileInput.addEventListener('change', () => {
  if (xmlFileInput.files[0]) loadXmlFile(xmlFileInput.files[0]);
});

/* ======== Load XML file ======== */
function loadXmlFile(file) {
  xmlFileName.textContent = file.name + ' (' + formatSize(file.size) + ')';
  xmlDropzone.classList.add('has-file');
  const reader = new FileReader();
  reader.onload = function(e) {
    const rawXml = e.target.result;
    resultXml = formatXml(rawXml);
    xmlPreview.innerHTML = highlightXml(resultXml);
    renderTeiPreview(rawXml);
    result.classList.add('active');
    // Update the result title for viewer mode
    const titleEl = result.querySelector('[data-i18n="resultTitle"]');
    if (titleEl) titleEl.textContent = t('viewerTitle');
  };
  reader.readAsText(file);
}

/* ======== Copy / Download ======== */
copyBtn.addEventListener('click', async () => {
  try {
    await navigator.clipboard.writeText(resultXml);
    copyBtn.textContent = t('copied');
    setTimeout(() => copyBtn.textContent = t('copy'), 1500);
  } catch {
    showError(t('errCopy'));
  }
});

downloadBtn.addEventListener('click', () => {
  const blob = new Blob([resultXml], { type: 'application/xml' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'output.xml';
  a.click();
  URL.revokeObjectURL(a.href);
});
