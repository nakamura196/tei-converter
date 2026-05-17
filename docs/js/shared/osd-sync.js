/* ======== osd-sync.js ========
   Scroll-synced single IIIF viewer: a two-panel reader where a scrolling
   transcription drives one OpenSeadragon viewer — as each page scrolls into
   view, the viewer shows that page's image and zones. Suited to long
   documents (one viewer instead of one-per-page).

   An XSL/HTML output uses it by emitting this markup and the script:

     <div class="osd-sync">
       <div class="osd-sync-text">
         <section class="osd-sync-page" data-iiif="https://…/info.json">
           …transcription…
           <script type="application/json" class="facsimile-zones">
             [ {"x":…,"y":…,"w":…,"h":…,"type":"line",
                "label":"1","target":"line-…"} , … ]
           </script>
         </section>
         …more pages…
       </div>
       <div class="osd-sync-view"></div>
     </div>
     <script src="js/shared/osd-sync.js"></script>

   * each .osd-sync-page carries its page image (data-iiif) and its zones.
   * a `[data-zone-toggle]` button toggles the zone overlays.

   OpenSeadragon is loaded on demand from a CDN. */
(function () {
  "use strict";

  var OSD_VERSION = "4.1.0";
  var OSD_JS  = "https://cdn.jsdelivr.net/npm/openseadragon@" + OSD_VERSION +
                "/build/openseadragon/openseadragon.min.js";
  var OSD_IMG = "https://cdn.jsdelivr.net/npm/openseadragon@" + OSD_VERSION +
                "/build/openseadragon/images/";

  function injectCss() {
    if (document.getElementById("osd-sync-css")) return;
    var css =
      ".osd-sync-view { position: relative; overflow: hidden; }" +
      ".osd-sync-view .osd-viewer { position: absolute; inset: 0;" +
        " width: 100%; height: 100%; }" +
      ".osdz { box-sizing: border-box; pointer-events: none; }" +
      ".osdz-line { border: 1.5px solid rgba(40,170,110,.9);" +
        " background: rgba(40,170,110,.1); }" +
      ".osdz-zone { border: 2px solid rgba(120,120,120,.9);" +
        " background: rgba(120,120,120,.12); }" +
      ".osdz-label { position: absolute; top: 0; left: 0;" +
        " font: 600 11px/1.5 monospace; padding: 0 4px;" +
        " white-space: nowrap; pointer-events: auto; cursor: default;" +
        " color: #fff; background: rgba(40,170,110,.95); }" +
      ".osdz-label.clickable { cursor: pointer; }" +
      ".osdz-label.clickable:hover { filter: brightness(1.15); }" +
      ".osd-sync-view.zones-hidden .osdz { display: none !important; }" +
      ".osd-sync-error { color: #d88; font: 14px/1.6 sans-serif; padding: 1rem; }";
    var style = document.createElement("style");
    style.id = "osd-sync-css";
    style.textContent = css;
    document.head.appendChild(style);
  }

  function loadOSD(cb) {
    if (window.OpenSeadragon) { cb(); return; }
    var existing = document.getElementById("osd-lib");
    if (existing) {
      existing.addEventListener("load", function () { cb(); });
      existing.addEventListener("error", function () { cb(new Error("load")); });
      return;
    }
    var sc = document.createElement("script");
    sc.id = "osd-lib";
    sc.src = OSD_JS;
    sc.onload = function () { cb(); };
    sc.onerror = function () { cb(new Error("load")); };
    document.head.appendChild(sc);
  }

  function tileSourceFor(iiif) {
    if (/\/info\.json$/i.test(iiif)) return iiif;
    if (/^(blob:|data:)/i.test(iiif) ||
        /\.(jpe?g|png|gif|webp|tiff?|avif)$/i.test(iiif)) {
      return { type: "image", url: iiif };
    }
    return iiif.replace(/\/+$/, "") + "/info.json";
  }

  function zonesOf(pageEl) {
    var el = pageEl.querySelector("script.facsimile-zones");
    if (!el) return [];
    try { return JSON.parse(el.textContent) || []; }
    catch (e) { return []; }
  }

  function boot() {
    var sync = document.querySelector(".osd-sync");
    if (!sync) return;
    var textEl = sync.querySelector(".osd-sync-text");
    var viewEl = sync.querySelector(".osd-sync-view");
    if (!textEl || !viewEl) return;
    var pages = [].slice.call(textEl.querySelectorAll(".osd-sync-page"));
    if (!pages.length) return;
    injectCss();

    /* zone-toggle button(s) */
    document.querySelectorAll("[data-zone-toggle]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        viewEl.classList.toggle("zones-hidden");
      });
    });

    loadOSD(function (err) {
      if (err) {
        viewEl.innerHTML = '<p class="osd-sync-error">' +
          'OpenSeadragon を読み込めませんでした。</p>';
        return;
      }
      start();
    });

    function start() {
      var osdEl = document.createElement("div");
      osdEl.className = "osd-viewer";
      viewEl.appendChild(osdEl);

      var viewer = OpenSeadragon({
        element: osdEl,
        prefixUrl: OSD_IMG,
        showNavigator: true,
        navigatorPosition: "BOTTOM_RIGHT",
        visibilityRatio: 1,
        minZoomImageRatio: 0.6,
        gestureSettingsMouse: { clickToZoom: false }
      });

      var pendingZones = [];
      viewer.addHandler("open", function () {
        viewer.clearOverlays();
        pendingZones.forEach(function (z) {
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
                if (t) t.scrollIntoView({ behavior: "smooth", block: "center",
                                          inline: "center" });
              });
            }
            el.appendChild(lab);
          }
          viewer.addOverlay({
            element: el,
            location: viewer.viewport.imageToViewportRectangle(
              z.x, z.y, z.w, z.h)
          });
        });
      });

      var currentPage = null;
      function showPage(pageEl) {
        if (!pageEl || pageEl === currentPage) return;
        var iiif = pageEl.getAttribute("data-iiif");
        if (!iiif) return;
        currentPage = pageEl;
        pendingZones = zonesOf(pageEl);
        viewer.open(tileSourceFor(iiif));
      }

      /* Pick the page most in view and sync the viewer to it. */
      var ratios = {};
      pages.forEach(function (p, i) { p.dataset.osdSyncIdx = i; ratios[i] = 0; });

      function pickBest() {
        var bestIdx = 0, best = -1;
        pages.forEach(function (p, i) {
          if (ratios[i] > best) { best = ratios[i]; bestIdx = i; }
        });
        showPage(pages[bestIdx]);
      }

      if (window.IntersectionObserver) {
        var io = new IntersectionObserver(function (entries) {
          entries.forEach(function (e) {
            ratios[e.target.dataset.osdSyncIdx] = e.intersectionRatio;
          });
          pickBest();
        }, { root: textEl, threshold: [0, 0.25, 0.5, 0.75, 1] });
        pages.forEach(function (p) { io.observe(p); });
      }
      showPage(pages[0]);   // initial
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
