/* ======== Full-screen TEI renderer ========
   Standalone (no common.js): reads ?url= and ?xsl= from the query string,
   transforms the TEI/XML with the browser's XSLTProcessor (XSLT 1.0), and
   replaces the whole document with the result.

   ?url=  the TEI/XML URL to render (relative or absolute)        [required]
   ?xsl=  a catalog id (reading / notes / bibliography / ocr)
          or the URL of an arbitrary XSL stylesheet              [optional]
          — omitted: guessed from the markup. */
"use strict";
(function () {
  var XSL_BY_ID = {
    reading:      'xsl/tei-reading.xsl',
    notes:        'xsl/tei-notes.xsl',
    bibliography: 'xsl/tei-bibliography.xsl',
    ocr:          'xsl/tei-ocr-facsimile.xsl',
    vellum:       'xsl/tei-vellum.xsl',
    urenja:       'xsl/tei-urenja.xsl',
  };

  var statusEl = document.getElementById('status');
  function fail(msg) {
    statusEl.className = 'status error';
    statusEl.textContent = msg;
  }

  var params   = new URLSearchParams(location.search);
  var urlParam = params.get('url');
  var xslParam = params.get('xsl');

  if (!urlParam) {
    statusEl.innerHTML = '?url= パラメータで TEI/XML の URL を指定してください。 / ' +
      'Specify a TEI/XML URL with the ?url= parameter.<br>' +
      '<a href="examples.html">← XSL ギャラリーへ / Back to the XSL Gallery</a>';
    return;
  }

  // A ?xsl= value is treated as a URL when it looks like one, else a catalog id.
  function resolveXslUrl(xslId, xmlText) {
    if (xslId && (/^https?:/i.test(xslId) || xslId.indexOf('/') !== -1 ||
                  /\.xslt?$/i.test(xslId))) {
      return new URL(xslId, location.href).href;
    }
    var id = xslId;
    if (!id || !XSL_BY_ID[id]) {
      id = (/<facsimile[\s>]/.test(xmlText) && /<graphic[\s>]/.test(xmlText))
        ? 'ocr' : 'reading';
    }
    return XSL_BY_ID[id];
  }

  async function fetchOk(u, what) {
    var r = await fetch(u);
    if (!r.ok) throw new Error(what + ' の取得に失敗しました / Failed to fetch ' +
      what + ': HTTP ' + r.status);
    return r;
  }

  (async function () {
    try {
      // Resolve to an absolute URL so relative ?url= and relative
      // <graphic url> paths both resolve correctly.
      var absXml  = new URL(urlParam, location.href).href;
      var xmlText = await (await fetchOk(absXml, 'XML')).text();
      var xslUrl  = resolveXslUrl(xslParam, xmlText);
      var xslText = await (await fetchOk(xslUrl, 'XSL')).text();

      var parser = new DOMParser();
      var xmlDoc = parser.parseFromString(xmlText, 'application/xml');
      if (xmlDoc.querySelector('parsererror')) {
        throw new Error('XML を解析できませんでした / Could not parse the XML.');
      }
      var xslDoc = parser.parseFromString(xslText, 'application/xml');
      if (xslDoc.querySelector('parsererror')) {
        throw new Error('XSL を解析できませんでした / Could not parse the XSL.');
      }

      // Resolve relative <graphic url> paths against the XML's own location.
      var graphics = xmlDoc.getElementsByTagNameNS('*', 'graphic');
      for (var i = 0; i < graphics.length; i++) {
        var u = graphics[i].getAttribute('url');
        if (u) {
          try { graphics[i].setAttribute('url', new URL(u, absXml).href); }
          catch (e) { /* leave as-is */ }
        }
      }

      var proc = new XSLTProcessor();
      proc.importStylesheet(xslDoc);
      var outDoc = proc.transformToDocument(xmlDoc);
      if (!outDoc || !outDoc.documentElement) {
        throw new Error('XSLT 変換に失敗しました / XSLT transformation failed.');
      }

      // Replace this whole document with the transformed result (full screen).
      var html = '<!DOCTYPE html>\n' + outDoc.documentElement.outerHTML;
      document.open();
      document.write(html);
      document.close();
    } catch (err) {
      fail(String(err && err.message ? err.message : err) +
        '  （外部 URL の場合は CORS 制限の可能性があります / ' +
        'for external URLs this may be a CORS restriction）');
    }
  })();
})();
