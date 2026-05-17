<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-urenja.xsl — Yūrensha transcription view / 酉蓮社 翻刻ビュー

  Title:       Yūrensha transcription view / 酉蓮社 翻刻ビュー
  Description: 酉蓮社（u-renja）プロジェクト専用。NDL古典籍OCR で生成した TEI を、左に縦書きの本文翻刻（全ページ連続スクロール）、右に OpenSeadragon の画像を 2 パネルで表示します。スクロールに連動して画像が切り替わります。/ The Yūrensha project stylesheet: a two-panel reader — a vertically-written, continuously scrolling transcription on the left, with a single OpenSeadragon viewer on the right that follows the scroll.
  Category:    プロジェクト専用 / Project-specific
  License:     自由に利用・改変できます（XSLT 1.0）。/ Free to use and adapt (XSLT 1.0).
  Sample:      u-renja DTS API の TEI（ライブ参照）

  facsimile の surface/zone/graphic と text の pb/lb を扱う。

  元の u-renja XSL と同じ 2 パネル構成（左に本文テキスト・連続スクロール、
  右に画像ビューア 1 つ）を踏襲しつつ、画像は Mirador ではなく OpenSeadragon
  を用いる。本文は古典籍に合わせて縦書き表示。

  共有モジュール（docs/js/shared/）を利用する:
    * tei-header.js … 上部バー＋ teiHeader モーダル
    * osd-sync.js   … スクロール連動の単一 OpenSeadragon ビューア
  XSL はページごとに .osd-sync-page（IIIF info.json ＋ zones JSON）を出力し、
  表示・スクロール連動ロジックは共有 JS が担う。XSLT 1.0。
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
      doctype-system="about:legacy-compat"/>

  <!-- xml:id は名前空間プレフィックスの有無に依存しないよう local-name() で照合 -->
  <xsl:key name="surface-by-id" match="tei:surface" use="@*[local-name() = 'id']"/>

  <xsl:variable name="title" select="normalize-space(//tei:titleStmt/tei:title)"/>

  <xsl:template match="/">
    <html lang="ja">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="$title"/></title>
        <style>
          * { box-sizing: border-box; }
          html, body { height: 100%; }
          body { font-family: "Hiragino Mincho ProN", "Yu Mincho",
                 "Noto Serif JP", serif; margin: 0; color: #1a1a1a;
                 background: #fafafa; line-height: 1.6; }

          /* ---- two-panel reader: text (left) + image viewer (right) ---- */
          .osd-sync { display: flex;
                      height: calc(100vh - var(--tei-bar-h, 52px)); }
          .osd-sync-text { flex: 1 1 52%; min-width: 0; padding: 1rem 1.25rem;
                           background: #fafafa;
                           /* 縦書き本文。ページ・行は右から左へ。横スクロール。 */
                           writing-mode: vertical-rl;
                           overflow-x: auto; overflow-y: hidden; }
          .osd-sync-view { flex: 1 1 48%; background: #1c1916; }

          /* ---- a page of transcription ---- */
          .osd-sync-page { display: block; border-left: 2px solid #e0ddd2;
                           padding-left: 1rem; margin-left: 1rem; }
          .osd-sync-page:first-child { border-left: 0; padding-left: 0;
                                       margin-left: 0; }
          .page-h { margin: 0 0 .5rem; font-size: .8rem; color: #8a8275;
                    font-weight: 600; letter-spacing: .08em; }

          /* ---- transcription lines (vertical columns) ---- */
          .lines { margin: 0; padding: 0; list-style: none; }
          .lines li { display: flex; gap: .5rem; padding: .3rem .25rem;
                      border-left: 1px dotted #e3e3e3; font-size: 1.1rem;
                      scroll-margin: calc(var(--tei-bar-h, 52px) + 8px); }
          .lines li:target { background: #fff6df; }
          .lineno { flex: 0 0 1.8rem; color: #aaa; font-size: .72rem;
                    text-align: center; text-orientation: upright;
                    font-variant-numeric: tabular-nums; }
          .linetext { white-space: pre-wrap; word-break: break-word;
                      line-height: 1.7; }
          .empty { color: #bbb; }
        </style>
      </head>
      <body>
        <!-- ===== two-panel reader (osd-sync.js drives the viewer) ===== -->
        <div class="osd-sync">
          <div class="osd-sync-text">
            <xsl:apply-templates select="//tei:body//tei:pb"/>
          </div>
          <div class="osd-sync-view"></div>
        </div>

        <!-- ===== teiHeader データ（共有ヘッダー: js/shared/tei-header.js） ===== -->
        <div class="tei-header" hidden="hidden" data-title="{$title}">
          <button type="button" class="tei-extra" data-zone-toggle="">ゾーン表示</button>
          <section class="tei-panel" data-label="書誌情報 / Metadata">
            <dl class="kv">
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'タイトル / Title'"/>
                <xsl:with-param name="value" select="//tei:titleStmt/tei:title"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'著者 / Author'"/>
                <xsl:with-param name="value" select="//tei:titleStmt/tei:author"/>
              </xsl:call-template>
              <dt>ページ数 / Pages</dt>
              <dd><xsl:value-of select="count(//tei:body//tei:pb)"/></dd>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'公開 / Publication'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:p"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'原資料 / Source'"/>
                <xsl:with-param name="value" select="//tei:sourceDesc/tei:p | //tei:sourceDesc/tei:bibl"/>
              </xsl:call-template>
            </dl>
          </section>
          <xsl:if test="//tei:titleStmt/tei:respStmt | //tei:publicationStmt/tei:respStmt">
            <section class="tei-panel" data-label="担当 / Responsibility">
              <dl class="kv">
                <xsl:for-each select="//tei:titleStmt/tei:respStmt | //tei:publicationStmt/tei:respStmt">
                  <dt><xsl:value-of select="normalize-space(tei:resp)"/></dt>
                  <dd>
                    <xsl:for-each select="tei:name">
                      <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
                      <xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                  </dd>
                </xsl:for-each>
              </dl>
            </section>
          </xsl:if>
        </div>

        <script src="js/shared/tei-header.js"></script>
        <script src="js/shared/osd-sync.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- ===== one page per <pb> ===== -->
  <xsl:template match="tei:pb">
    <xsl:variable name="surface"
        select="key('surface-by-id', substring-after(@facs, '#'))"/>
    <xsl:variable name="graphic" select="$surface/tei:graphic"/>
    <!-- IIIF info.json (zoomable) when an image id is available, else the
         ready-made image URL. -->
    <xsl:variable name="iiif">
      <xsl:choose>
        <xsl:when test="$graphic/@sameAs">
          <xsl:value-of select="concat($graphic/@sameAs, '/info.json')"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$graphic/@url"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- lines belonging to this page: following <lb> up to the next <pb> -->
    <xsl:variable name="lines" select="following-sibling::tei:lb[
        generate-id(preceding-sibling::tei:pb[1]) = generate-id(current())]"/>
    <section class="osd-sync-page" id="page-{@n}" data-iiif="{$iiif}">
      <h3 class="page-h">ページ <xsl:value-of select="@n"/></h3>
      <ol class="lines">
        <xsl:for-each select="$lines">
          <xsl:variable name="text"
              select="normalize-space(following-sibling::text()[1])"/>
          <li id="line-{substring-after(@corresp, '#')}">
            <span class="lineno"><xsl:value-of select="@n"/></span>
            <xsl:choose>
              <xsl:when test="$text != ''">
                <span class="linetext"><xsl:value-of select="$text"/></span>
              </xsl:when>
              <xsl:otherwise>
                <span class="linetext empty">(空行 / empty)</span>
              </xsl:otherwise>
            </xsl:choose>
          </li>
        </xsl:for-each>
      </ol>
      <!-- zone overlays for this page, consumed by osd-sync.js -->
      <script type="application/json" class="facsimile-zones">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$surface/tei:zone">
          <xsl:if test="position() &gt; 1"><xsl:text>,</xsl:text></xsl:if>
          <xsl:variable name="zid" select="@*[local-name()='id']"/>
          <xsl:variable name="lb"
              select="//tei:lb[@corresp = concat('#', $zid)]"/>
          <xsl:text>{"x":</xsl:text><xsl:value-of select="number(@ulx)"/>
          <xsl:text>,"y":</xsl:text><xsl:value-of select="number(@uly)"/>
          <xsl:text>,"w":</xsl:text>
          <xsl:value-of select="number(@lrx) - number(@ulx)"/>
          <xsl:text>,"h":</xsl:text>
          <xsl:value-of select="number(@lry) - number(@uly)"/>
          <xsl:text>,"type":"line","label":"</xsl:text>
          <xsl:choose>
            <xsl:when test="$lb/@n"><xsl:value-of select="$lb/@n"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="position()"/></xsl:otherwise>
          </xsl:choose>
          <xsl:text>","target":"line-</xsl:text>
          <xsl:value-of select="$zid"/><xsl:text>"}</xsl:text>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </script>
    </section>
  </xsl:template>

  <!-- ===== Helper: one key/value row, skipped when empty ===== -->
  <xsl:template name="kv">
    <xsl:param name="label"/>
    <xsl:param name="value"/>
    <xsl:if test="normalize-space($value) != ''">
      <dt><xsl:value-of select="$label"/></dt>
      <dd><xsl:value-of select="normalize-space($value)"/></dd>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
