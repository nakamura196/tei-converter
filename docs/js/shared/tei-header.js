/* ======== tei-header.js ========
   Reusable top bar + teiHeader modal for project TEI views.

   Any XSL/HTML output can use it — no build step, no per-project code — by
   emitting this markup once and including this script:

     <div class="tei-header" data-title="Document title">
       <section class="tei-panel" data-label="概要 / Overview">
         …arbitrary metadata HTML (dl.kv, h3, p, p.tei-bibl, …)…
       </section>
       <section class="tei-panel" data-label="写本記述 / MS Description">
         …
       </section>
       <button type="button" class="tei-extra" data-zone-toggle>ゾーン表示</button>
     </div>
     <script src="tei-header.js"></script>

   On load it builds a sticky top bar: the document title plus one menu
   button per `.tei-panel`. Clicking a button opens a modal showing that
   panel's content. Any `.tei-extra` element (e.g. an osd-facsimile.js
   zone-toggle button) is moved into the bar as-is.

   It exposes the bar height as the CSS variable `--tei-bar-h`, so page
   layout can offset for it with `var(--tei-bar-h, 52px)`.

   Shared by tei-vellum.xsl and tei-urenja.xsl. */
(function () {
  "use strict";

  function injectCss() {
    if (document.getElementById("tei-header-css")) return;
    var css =
      ":root { --tei-bar-h: 52px; }" +
      ".tei-topbar { position: sticky; top: 0; z-index: 40;" +
        " height: var(--tei-bar-h); display: flex; align-items: center;" +
        " gap: 1rem; padding: 0 1rem; background: #2c2622; color: #f3f1ea; }" +
      ".tei-brand { font-size: .9rem; font-weight: 600; flex: 1; min-width: 0;" +
        " white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }" +
      ".tei-nav { display: flex; gap: .25rem; flex: none; flex-wrap: wrap;" +
        " justify-content: flex-end; }" +
      ".tei-nav button { font: inherit; font-size: .8rem; cursor: pointer;" +
        " color: #f3f1ea; background: transparent; border: 0;" +
        " padding: .4rem .7rem; border-radius: 6px; }" +
      ".tei-nav button:hover { background: rgba(255,255,255,.14); }" +
      ".tei-nav button.tei-extra-on { background: rgba(216,184,138,.3); }" +
      ".tei-modal { display: none; position: fixed; inset: 0; z-index: 50;" +
        " background: rgba(20,17,14,.55);" +
        " padding: calc(var(--tei-bar-h) + 1rem) 1rem 1rem; }" +
      ".tei-modal.open { display: flex; justify-content: center;" +
        " align-items: flex-start; }" +
      ".tei-modal-box { background: #fff; border-radius: 12px; max-width: 640px;" +
        " width: 100%; max-height: 100%; overflow: auto;" +
        " padding: 1.3rem 1.6rem 1.6rem; position: relative;" +
        " font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;" +
        " color: #1a1a1a; }" +
      ".tei-modal-close { position: absolute; top: .7rem; right: .8rem;" +
        " font-size: 1.3rem; line-height: 1; cursor: pointer;" +
        " background: transparent; border: 0; color: #888; }" +
      ".tei-modal-section h2 { font-size: 1.1rem; margin: 0 0 .9rem;" +
        " color: #8a6d3b; }" +
      ".tei-modal-section h3 { font-size: .9rem; margin: 1.1rem 0 .3rem; }" +
      ".tei-modal-section p { font-size: .86rem; line-height: 1.7;" +
        " margin: .4rem 0; }" +
      ".tei-modal-section dl.kv { display: grid;" +
        " grid-template-columns: max-content 1fr; gap: .35rem .9rem;" +
        " margin: 0; font-size: .87rem; }" +
      ".tei-modal-section dl.kv dt { color: #8a8275; white-space: nowrap; }" +
      ".tei-modal-section dl.kv dd { margin: 0; }" +
      ".tei-modal-section .tei-bibl { padding-left: 1.1em;" +
        " text-indent: -1.1em; }";
    var style = document.createElement("style");
    style.id = "tei-header-css";
    style.textContent = css;
    document.head.appendChild(style);
  }

  function boot() {
    var src = document.querySelector(".tei-header");
    if (!src) return;
    injectCss();

    var title = src.getAttribute("data-title") ||
      (document.title || "TEI Document");
    var panels = [].slice.call(src.querySelectorAll(":scope > .tei-panel"));
    var extras = [].slice.call(src.querySelectorAll(":scope > .tei-extra"));

    /* ---- modal ---- */
    var modal = document.createElement("div");
    modal.className = "tei-modal";
    var box = document.createElement("div");
    box.className = "tei-modal-box";
    var close = document.createElement("button");
    close.type = "button";
    close.className = "tei-modal-close";
    close.setAttribute("aria-label", "close");
    close.innerHTML = "&#215;";
    box.appendChild(close);
    modal.appendChild(box);

    function closeModal() { modal.classList.remove("open"); }
    function openSection(sec) {
      modal.classList.add("open");
      [].forEach.call(box.querySelectorAll(".tei-modal-section"), function (s) {
        s.style.display = (s === sec) ? "block" : "none";
      });
    }
    close.addEventListener("click", closeModal);
    modal.addEventListener("click", function (e) {
      if (e.target === modal) closeModal();
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") closeModal();
    });

    /* ---- top bar ---- */
    var bar = document.createElement("header");
    bar.className = "tei-topbar";
    var brand = document.createElement("div");
    brand.className = "tei-brand";
    brand.textContent = title;
    brand.title = title;
    var nav = document.createElement("nav");
    nav.className = "tei-nav";
    bar.appendChild(brand);
    bar.appendChild(nav);

    panels.forEach(function (panel, i) {
      var label = panel.getAttribute("data-label") || ("Panel " + (i + 1));
      var section = document.createElement("section");
      section.className = "tei-modal-section";
      section.style.display = "none";
      var h2 = document.createElement("h2");
      h2.textContent = label;
      section.appendChild(h2);
      while (panel.firstChild) section.appendChild(panel.firstChild);
      box.appendChild(section);

      var btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = label;
      btn.addEventListener("click", function () { openSection(section); });
      nav.appendChild(btn);
    });

    /* extras (e.g. a zone-toggle button) move into the bar untouched */
    extras.forEach(function (el) { nav.appendChild(el); });

    document.body.insertBefore(bar, document.body.firstChild);
    document.body.appendChild(modal);
    src.parentNode.removeChild(src);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
