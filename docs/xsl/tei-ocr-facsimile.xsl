<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-ocr-facsimile.xsl — OCR transcription view / OCR 翻刻ビュー

  Title:       OCR transcription view / OCR 翻刻ビュー
  Description: OCR 出力の TEI を、ページ画像と行ごとの翻刻テキストを左右に並べて表示する検証ビューです。/ A verification view placing each page image beside its numbered OCR lines.
  Category:    汎用 / General-purpose
  License:     自由に利用・改変できます（XSLT 1.0）。/ Free to use and adapt (XSLT 1.0).
  Sample:      xml/ocr-sample/ （tei.xml + images/）

  facsimile の surface/zone/graphic と text の pb/lb を扱う。
  TEIScanner / NDL古典籍OCR などの OCR 結果を想定。

  共有モジュール（docs/js/shared/）を利用する:
    * tei-header.js    … 上部バー＋ teiHeader モーダル
    * osd-facsimile.js … OpenSeadragon による拡大縮小＋行 zone のオーバーレイ
  XSL はページごとに .facsimile（IIIF/画像 URL ＋ zones JSON）を出力し、
  表示ロジックは共有 JS が担う。XSLT 1.0。

  画像は <graphic url="..."/> の相対パスで参照する。view.html / examples.html
  経由ではアプリ側が url を解決してから変換に渡す。
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
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="$title"/></title>
        <style>
          * { box-sizing: border-box; }
          body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
                 margin: 0; color: #1a1a1a; background: #fafafa; line-height: 1.6; }
          .ocr-intro { padding: 1rem clamp(1rem,4vw,2.5rem) 0;
                       color: #666; font-size: .85rem; }
          .tei-page { padding: 1.2rem clamp(1rem,4vw,2.5rem); }
          .page-h { margin: 0 0 .8rem; font-size: .95rem; color: #555;
                    letter-spacing: .04em; }
          .page-grid { display: flex; gap: 1.5rem; align-items: flex-start; }
          /* 左にテキスト、右に画像（vellum ビューと共通の並び）。
             order で制御するのでモバイル縦積み時もテキストが上に来る。 */
          .facsimile-col { flex: 1 1 50%; min-width: 0; order: 1; }
          .facsimile-col .facsimile { width: 100%; height: 460px;
                                      border: 1px solid #ccc; background: #1c1916;
                                      border-radius: 6px; }
          .lines { flex: 1 1 50%; min-width: 0; order: 0; margin: 0; padding: 0;
                   list-style: none; }
          .lines li { display: flex; gap: .75rem; padding: .25rem .3rem;
                      border-bottom: 1px dotted #e3e3e3; font-size: .95rem;
                      scroll-margin-top: calc(var(--tei-bar-h, 52px) + 8px); }
          .lines li:target { background: #fff6df; }
          .lineno { flex: 0 0 2rem; text-align: right; color: #aaa;
                    font-variant-numeric: tabular-nums; }
          .linetext { white-space: pre-wrap; word-break: break-word; }
          .empty { color: #bbb; }
          @media (max-width: 720px) {
            .page-grid { flex-direction: column; }
            .facsimile-col { width: 100%; }
          }
        </style>
      </head>
      <body>
        <p class="ocr-intro">
          <xsl:text>OCR 翻刻ビュー / OCR transcription view — </xsl:text>
          <xsl:value-of select="count(//tei:body//tei:pb)"/>
          <xsl:text> ページ。画像はドラッグで移動・ホイールで拡大縮小できます。</xsl:text>
        </p>

        <!-- ページャー: tei-pager.js が 1 ページずつ表示する -->
        <div class="tei-pager">
          <xsl:apply-templates select="//tei:body//tei:pb"/>
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
                <xsl:with-param name="label" select="'出版 / Publisher'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:publisher"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'日付 / Date'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:date"/>
              </xsl:call-template>
              <xsl:if test="//tei:publicationStmt/tei:date/@when">
                <dt>日付 (when)</dt>
                <dd><xsl:value-of select="//tei:publicationStmt/tei:date/@when"/></dd>
              </xsl:if>
              <dt>ページ数 / Pages</dt>
              <dd><xsl:value-of select="count(//tei:body//tei:pb)"/></dd>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'原資料 / Source'"/>
                <xsl:with-param name="value" select="//tei:sourceDesc/tei:p | //tei:sourceDesc/tei:bibl"/>
              </xsl:call-template>
            </dl>
            <xsl:for-each select="//tei:titleStmt/tei:respStmt">
              <h3><xsl:value-of select="normalize-space(tei:resp)"/></h3>
              <p>
                <xsl:for-each select="tei:name">
                  <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:for-each>
              </p>
            </xsl:for-each>
          </section>
        </div>

        <script src="js/shared/tei-header.js"></script>
        <script src="js/shared/tei-pager.js"></script>
        <script src="js/shared/osd-facsimile.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- ===== one page per <pb> ===== -->
  <xsl:template match="tei:pb">
    <xsl:variable name="surface"
        select="key('surface-by-id', substring-after(@facs, '#'))"/>
    <!-- lines belonging to this page: following <lb> up to the next <pb> -->
    <xsl:variable name="lines" select="following-sibling::tei:lb[
        generate-id(preceding-sibling::tei:pb[1]) = generate-id(current())]"/>
    <section class="tei-page" data-page-label="ページ {@n}">
      <h2 class="page-h">ページ / Page <xsl:value-of select="@n"/></h2>
      <div class="page-grid">
        <div class="facsimile-col">
          <xsl:choose>
            <xsl:when test="$surface/tei:graphic/@url">
              <!-- osd-facsimile.js mounts OpenSeadragon here -->
              <div class="facsimile" data-iiif="{$surface/tei:graphic/@url}">
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
              </div>
            </xsl:when>
            <xsl:otherwise>
              <p class="empty">（画像なし / no image）</p>
            </xsl:otherwise>
          </xsl:choose>
        </div>
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
      </div>
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
