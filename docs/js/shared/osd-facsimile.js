/* ======== osd-facsimile.js ========
   Reusable IIIF facsimile viewer with zone overlays, built on OpenSeadragon.

   Any XSL/HTML output can use it — no build step, no per-project code — by
   emitting this markup and including this script:

     <div class="facsimile" data-iiif="https://…/image.tif/info.json">
       <script type="application/json" class="facsimile-zones">
         [ {"x":54,"y":512,"w":4640,"h":1243,
            "type":"deed","label":"Deed 1","target":"deed-1"} , … ]
       </script>
     </div>
     <script src="js/shared/osd-facsimile.js"></script>

   * data-iiif — a IIIF `info.json` URL, a IIIF image id (→ `/info.json` is
     appended), a plain image URL, or a blob:/data: URL (→ a non-tiled image).
   * zones — array of { x, y, w, h, type, label?, target? } in the image's
     native pixel coordinates. `type` becomes a CSS modifier (osdz-<type>);
     `label` is shown at the zone's corner; `target`, if set, makes the label
     clickable and scrolls the element with that id into view.
   * A `[data-zone-toggle]` button anywhere on the page toggles zone overlays.

   Lazy mounting: containers that are visible on load are mounted immediately;
   hidden containers (e.g. inside a paged view — see tei-pager.js) are mounted
   on demand via `window.OSDFacsimile.mount(container)`.

   Used by tei-vellum.xsl and tei-ocr-facsimile.xsl; reusable by any project.
   OpenSeadragon is loaded on demand from a CDN. */
(function () {
  "use strict";

  var OSD_VERSION = "4.1.0";
  var OSD_JS  = "https://cdn.jsdelivr.net/npm/openseadragon@" + OSD_VERSION +
                "/build/openseadragon/openseadragon.min.js";
  var OSD_IMG = "https://cdn.jsdelivr.net/npm/openseadragon@" + OSD_VERSION +
                "/build/openseadragon/images/";

  var osdState = "idle";   // idle | loading | ready | failed
  var queue = [];          // containers waiting for the OSD library

  /* ---- inject the (one-time) stylesheet ---- */
  function injectCss() {
    if (document.getElementById("osd-facsimile-css")) return;
    var css =
      ".facsimile { position: relative; overflow: hidden; }" +
      ".facsimile .osd-viewer { position: absolute; inset: 0;" +
        " width: 100%; height: 100%; }" +
      ".osdz { box-sizing: border-box; pointer-events: none; }" +
      ".osdz-deed { border: 2px solid rgba(220,140,40,.92);" +
        " background: rgba(220,140,40,.12); }" +
      ".osdz-signature { border: 2px solid rgba(70,120,210,.92);" +
        " background: rgba(70,120,210,.14); }" +
      ".osdz-line { border: 1.5px solid rgba(40,170,110,.9);" +
        " background: rgba(40,170,110,.1); }" +
      ".osdz-zone { border: 2px solid rgba(120,120,120,.9);" +
        " background: rgba(120,120,120,.12); }" +
      ".osdz-label { position: absolute; top: 0; left: 0;" +
        " font: 600 11px/1.5 monospace; padding: 0 4px;" +
        " white-space: nowrap; pointer-events: auto; cursor: default;" +
        " color: #fff; }" +
      ".osdz-deed .osdz-label { background: rgba(220,140,40,.95); }" +
      ".osdz-signature .osdz-label { background: rgba(70,120,210,.95); }" +
      ".osdz-line .osdz-label { background: rgba(40,170,110,.95); }" +
      ".osdz-zone .osdz-label { background: rgba(90,90,90,.95); }" +
      ".osdz-label.clickable { cursor: pointer; }" +
      ".osdz-label.clickable:hover { filter: brightness(1.15); }" +
      /* !important: OpenSeadragon sets `display` inline on overlay
         elements, so a plain class rule would be overridden. */
      ".facsimile.zones-hidden .osdz { display: none !important; }" +
      ".facsimile-error { color: #d88; font: 14px/1.6 sans-serif;" +
        " padding: 1rem; }";
    var style = document.createElement("style");
    style.id = "osd-facsimile-css";
    style.textContent = css;
    document.head.appendChild(style);
  }

  /* ---- load OpenSeadragon once ---- */
  function ensureOSD() {
    if (osdState === "ready") { flushQueue(); return; }
    if (osdState === "loading" || osdState === "failed") return;
    if (window.OpenSeadragon) { osdState = "ready"; flushQueue(); return; }
    osdState = "loading";
    var sc = document.createElement("script");
    sc.id = "osd-lib";
    sc.src = OSD_JS;
    sc.onload = function () { osdState = "ready"; flushQueue(); };
    sc.onerror = function () {
      osdState = "failed";
      queue.forEach(function (c) {
        showError(c, new Error("OpenSeadragon を読み込めませんでした。"));
      });
      queue = [];
    };
    document.head.appendChild(sc);
  }

  function flushQueue() {
    var pending = queue;
    queue = [];
    pending.forEach(mountContainer);
  }

  /* ---- turn data-iiif into an OpenSeadragon tile source ---- */
  function tileSourceFor(iiif) {
    if (/\/info\.json$/i.test(iiif)) return iiif;
    /* blob:/data: URLs (e.g. from a folder upload) and plain image files
       have no IIIF service — show them as a single non-tiled image. */
    if (/^(blob:|data:)/i.test(iiif) ||
        /\.(jpe?g|png|gif|webp|tiff?|avif)$/i.test(iiif)) {
      return { type: "image", url: iiif };
    }
    return iiif.replace(/\/+$/, "") + "/info.json";
  }

  function showError(container, err) {
    var p = document.createElement("p");
    p.className = "facsimile-error";
    p.textContent = (err && err.message) ? err.message
      : "facsimile を表示できませんでした。";
    container.appendChild(p);
  }

  /* ---- mount one .facsimile container (idempotent) ---- */
  function mountContainer(container) {
    if (container._osdInited) {
      if (container._osdViewer) container._osdViewer.forceRedraw();
      return;
    }
    container._osdInited = true;

    var iiif = container.getAttribute("data-iiif");
    if (!iiif) { showError(container, new Error("data-iiif がありません。")); return; }

    var zones = [];
    var dataEl = container.querySelector("script.facsimile-zones");
    if (dataEl) {
      try { zones = JSON.parse(dataEl.textContent) || []; }
      catch (e) { zones = []; }
    }

    var viewerEl = document.createElement("div");
    viewerEl.className = "osd-viewer";
    container.appendChild(viewerEl);

    var viewer = OpenSeadragon({
      element: viewerEl,
      prefixUrl: OSD_IMG,
      tileSources: tileSourceFor(iiif),
      showNavigator: true,
      navigatorPosition: "BOTTOM_RIGHT",
      visibilityRatio: 1,
      minZoomImageRatio: 0.6,
      gestureSettingsMouse: { clickToZoom: false }
    });
    container._osdViewer = viewer;

    viewer.addHandler("open", function () {
      zones.forEach(function (z) {
        if (!(z.w > 0 && z.h > 0)) return;
        var el = document.createElement("div");
        el.className = "osdz osdz-" + (z.type || "zone");
        if (z.label) {
          var lab = document.createElement("span");
          lab.className = "osdz-label";
          lab.textContent = z.label;
          if (z.target) {
            lab.className += " clickable";
            lab.title = "本文へ移動 / jump to text";
            lab.addEventListener("click", function () {
              var t = document.getElementById(z.target);
              if (t) t.scrollIntoView({ behavior: "smooth", block: "center" });
            });
          }
          el.appendChild(lab);
        }
        viewer.addOverlay({
          element: el,
          location: viewer.viewport.imageToViewportRectangle(z.x, z.y, z.w, z.h)
        });
      });
    });

    viewer.addHandler("open-failed", function () {
      showError(container,
        new Error("画像を読み込めませんでした / Could not load the image."));
    });
  }

  /* ---- request a container be mounted (now or when OSD is ready) ---- */
  function requestMount(container) {
    if (!container || container._osdInited) {
      if (container && container._osdViewer) container._osdViewer.forceRedraw();
      return;
    }
    if (osdState === "ready") { mountContainer(container); return; }
    if (osdState === "failed") {
      showError(container, new Error("OpenSeadragon を読み込めませんでした。"));
      return;
    }
    if (queue.indexOf(container) === -1) queue.push(container);
    ensureOSD();
  }

  /* a container is "visible" when it has a layout box (not display:none) */
  function isVisible(el) {
    return !!(el.offsetParent || el.offsetWidth || el.offsetHeight);
  }

  /* ---- wire any [data-zone-toggle] button to show/hide overlays ---- */
  function wireToggles() {
    document.querySelectorAll("[data-zone-toggle]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        document.querySelectorAll(".facsimile").forEach(function (c) {
          c.classList.toggle("zones-hidden");
        });
      });
    });
  }

  /* Public API — paged views (tei-pager.js) call mount() when a hidden
     page becomes visible. */
  window.OSDFacsimile = {
    mount: requestMount,
    mountWithin: function (root) {
      (root || document).querySelectorAll(".facsimile[data-iiif]")
        .forEach(requestMount);
    }
  };

  function boot() {
    var containers = document.querySelectorAll(".facsimile[data-iiif]");
    if (!containers.length) return;
    injectCss();
    wireToggles();
    /* Mount visible containers now; hidden ones wait for OSDFacsimile.mount. */
    containers.forEach(function (c) {
      if (isVisible(c)) requestMount(c);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
