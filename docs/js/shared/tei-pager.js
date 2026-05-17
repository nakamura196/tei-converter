/* ======== tei-pager.js ========
   Reusable page-by-page navigator for multi-page TEI views.

   Any XSL/HTML output can use it by emitting this markup and the script:

     <div class="tei-pager">
       <section class="tei-page" data-page-label="ページ 1">…</section>
       <section class="tei-page" data-page-label="ページ 2">…</section>
       …
     </div>
     <script src="js/shared/tei-pager.js"></script>

   It shows one `.tei-page` at a time with a sticky prev / next bar and a
   counter; ←/→ keys also navigate. With a single page, no bar is shown.

   Page visibility is driven by an inline `display` style set directly on
   each `.tei-page`, so it cannot be overridden by project CSS.

   If osd-facsimile.js is present, any `.facsimile` viewers inside a page are
   mounted lazily — only when that page is first shown — via
   `window.OSDFacsimile.mountWithin(page)`. This keeps many-page documents
   light: only the current page's OpenSeadragon viewer is initialised.

   Load order: include this BEFORE osd-facsimile.js so that, by the time
   osd-facsimile boots, off-screen pages are already hidden and their
   viewers are skipped. */
(function () {
  "use strict";

  function injectCss() {
    if (document.getElementById("tei-pager-css")) return;
    var css =
      ".tei-pager-bar { position: sticky; top: var(--tei-bar-h, 52px);" +
        " z-index: 25; display: flex; align-items: center;" +
        " justify-content: center; gap: 1rem; padding: .5rem 1rem;" +
        " background: #efece4; border-bottom: 1px solid #d8d2c2; }" +
      ".tei-pager-bar button { font: inherit; font-size: .85rem;" +
        " cursor: pointer; padding: .35rem .9rem; border-radius: 6px;" +
        " border: 1px solid #c8c2b2; background: #fff; color: #2c2622; }" +
      ".tei-pager-bar button:hover:not(:disabled) { background: #f3f1ea; }" +
      ".tei-pager-bar button:disabled { opacity: .4; cursor: default; }" +
      ".tei-pager-counter { font-size: .85rem; color: #5b5346;" +
        " min-width: 8rem; text-align: center;" +
        " font-variant-numeric: tabular-nums; }";
    var style = document.createElement("style");
    style.id = "tei-pager-css";
    style.textContent = css;
    document.head.appendChild(style);
  }

  function boot() {
    var pager = document.querySelector(".tei-pager");
    if (!pager) return;
    injectCss();

    /* direct-child .tei-page sections (no :scope, for max compatibility) */
    var pages = [];
    for (var c = pager.firstElementChild; c; c = c.nextElementSibling) {
      if (c.classList && c.classList.contains("tei-page")) pages.push(c);
    }
    if (!pages.length) return;

    function mountViewers(page) {
      if (window.OSDFacsimile && window.OSDFacsimile.mountWithin) {
        window.OSDFacsimile.mountWithin(page);
      }
    }

    var current = -1;

    /* Single page: just show it, no navigation bar. */
    if (pages.length === 1) {
      pages[0].style.display = "block";
      pages[0].classList.add("tei-page-active");
      mountViewers(pages[0]);
      return;
    }

    /* ---- navigation bar ---- */
    var bar = document.createElement("div");
    bar.className = "tei-pager-bar";
    var prev = document.createElement("button");
    prev.type = "button";
    prev.textContent = "‹ 前へ";
    var counter = document.createElement("span");
    counter.className = "tei-pager-counter";
    var next = document.createElement("button");
    next.type = "button";
    next.textContent = "次へ ›";
    bar.appendChild(prev);
    bar.appendChild(counter);
    bar.appendChild(next);
    pager.insertBefore(bar, pager.firstChild);

    function label(i) {
      var l = pages[i].getAttribute("data-page-label");
      return (l ? l : "ページ " + (i + 1)) + " / " + pages.length;
    }

    function show(i) {
      if (i < 0 || i >= pages.length) return;
      current = i;
      for (var k = 0; k < pages.length; k++) {
        /* inline display — beats any project CSS */
        pages[k].style.display = (k === i) ? "block" : "none";
        if (k === i) pages[k].classList.add("tei-page-active");
        else pages[k].classList.remove("tei-page-active");
      }
      counter.textContent = label(i);
      prev.disabled = (i === 0);
      next.disabled = (i === pages.length - 1);
      mountViewers(pages[i]);                 // lazy-mount this page's viewers
      bar.scrollIntoView({ block: "nearest" });
    }

    prev.addEventListener("click", function () { show(current - 1); });
    next.addEventListener("click", function () { show(current + 1); });
    document.addEventListener("keydown", function (e) {
      if (e.target && /^(INPUT|TEXTAREA|SELECT)$/.test(e.target.tagName)) return;
      if (e.key === "ArrowLeft") show(current - 1);
      else if (e.key === "ArrowRight") show(current + 1);
    });

    show(0);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
