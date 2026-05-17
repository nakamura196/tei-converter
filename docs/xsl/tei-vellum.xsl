<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-vellum.xsl — Vellum contract document view / Vellum 契約文書ビュー

  Title:       Vellum contract document view / Vellum 契約文書ビュー
  Description: 東洋文庫「モロッコの羊皮紙契約文書」プロジェクト専用。写本記述・IIIF 画像・各証文（deed）のアラビア語翻刻（RTL）を表示します。/ Dedicated to the Toyo Bunko "Vellum Contract Documents from Morocco" project: manuscript description, IIIF image and the right-to-left Arabic transcription of each deed.
  Category:    プロジェクト専用 / Project-specific
  License:     自由に利用・改変できます（XSLT 1.0）。/ Free to use and adapt (XSLT 1.0).
  Sample:      xml/vellum/tei.xml

  東洋文庫「モロッコの羊皮紙契約文書（Vellum Contract Documents）」プロジェクトの
  TEI 専用スタイルシート。

  この TEI の独自構造:
    * teiHeader/sourceDesc/msDesc … 写本記述（来歴・寸法・所蔵）
    * facsimile/surface/graphic … IIIF 画像（@sameAs が IIIF 画像 ID）
    * facsimile//zone … 証文(@type='deed')・署名(@type='signature')の領域
    * body/div[@type='deed'] … 証文 1 通ごと（全 10 通）
    * ab[@type='nass'] … 証文内の「nāṣṣ（本文）」ブロック
    * seg[@rend='underline'] … nāṣṣ の見出しラベル
    * seg[@type='sigil'] … 署名記号（{I-S1} など）
    * note[@place='foot'] … 校訂注

  出力レイアウト（完結した HTML 文書、XSLT 1.0）:
    * 左にアラビア語翻刻（RTL）、右に IIIF 原本画像。
    * 共有モジュールを利用する（docs/js/shared/ に配置）:
        - tei-header.js   … 上部バー＋ teiHeader モーダル
        - osd-facsimile.js … OpenSeadragon による拡大縮小＋ zone 表示
      XSL はデータ（.tei-header パネル / .facsimile + zones JSON）を出力し、
      表示ロジックは共有 JS が担う。u-renja など他プロジェクトと共通。
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
      doctype-system="about:legacy-compat"/>

  <xsl:variable name="title"
      select="normalize-space(//tei:titleStmt/tei:title[not(@type)])"/>
  <xsl:variable name="iiif" select="string(//tei:facsimile//tei:graphic/@sameAs)"/>
  <xsl:variable name="facsUrl" select="string(//tei:facsimile//tei:graphic/@url)"/>
  <!-- data-iiif for osd-facsimile.js: an info.json URL when a IIIF id is
       available, otherwise the plain image URL. -->
  <xsl:variable name="iiifData">
    <xsl:choose>
      <xsl:when test="$iiif != ''"><xsl:value-of select="concat($iiif, '/info.json')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$facsUrl"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="$title"/></title>
        <style>
          :root { --accent: #8a6d3b; }
          * { box-sizing: border-box; }
          body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
                 margin: 0; color: #1a1a1a; background: #f3f1ea; }

          /* ---- two-column reader ---- */
          .reader { display: flex; align-items: flex-start; }
          .text-pane { flex: 1 1 54%; min-width: 0;
                       padding: 1.5rem clamp(1rem,3vw,2.5rem); }
          .image-pane { flex: 1 1 46%; align-self: stretch;
                        position: sticky; top: var(--tei-bar-h, 52px);
                        height: calc(100vh - var(--tei-bar-h, 52px));
                        background: #1c1916; }
          .image-pane .facsimile { width: 100%; height: 100%; }

          /* ---- deeds ---- */
          .pane-h { font-size: .95rem; color: #6b6256; letter-spacing: .04em;
                    border-bottom: 2px solid #d8d2c2; padding-bottom: .35rem;
                    margin: 0 0 1rem; }
          .deed { background: #fff; border: 1px solid #e3ddcc; border-radius: 10px;
                  padding: 1rem 1.3rem 1.2rem; margin: 0 0 1.1rem;
                  scroll-margin-top: calc(var(--tei-bar-h, 52px) + 8px); }
          .deed-h { margin: 0 0 .6rem; font-size: 1rem; color: var(--accent);
                    border-bottom: 1px dashed #e3ddcc; padding-bottom: .35rem; }
          .deed-text { direction: rtl; text-align: justify;
                       font-family: "Geeza Pro", "Noto Naskh Arabic", "Times New Roman", serif;
                       font-size: 1.18rem; line-height: 2.2; }
          .nass-label { font-weight: bold; text-decoration: underline;
                        text-underline-offset: 3px; }
          .sigil { direction: ltr; display: inline-block; font-family: monospace;
                   font-size: .8em; background: #eef0f4; color: #4a5b78;
                   border-radius: 4px; padding: 0 .35em; margin: 0 .15em;
                   vertical-align: .1em; }
          .note-ref { direction: ltr; display: inline-block; color: #1a6cff;
                      font-size: .7em; vertical-align: super; font-weight: bold; }
          .deed-notes { direction: ltr; text-align: left; margin: .8rem 0 0;
                        padding: .6rem 1rem; list-style: none;
                        background: #faf8f2; border-radius: 7px;
                        font-size: .82rem; color: #555; line-height: 1.6; }
          .deed-notes li { margin: .2rem 0; }
          .fn-no { color: var(--accent); font-weight: bold; }

          @media (max-width: 720px) {
            .reader { flex-direction: column; }
            .image-pane { position: static; height: 65vh; width: 100%; }
          }
        </style>
      </head>
      <body>
        <!-- ===== two-column reader ===== -->
        <div class="reader">
          <section class="text-pane">
            <h2 class="pane-h">
              <xsl:text>証文 / Deeds (</xsl:text>
              <xsl:value-of select="count(//tei:body/tei:div[@type='deed'])"/>
              <xsl:text>)</xsl:text>
            </h2>
            <xsl:apply-templates select="//tei:body/tei:div[@type='deed']"/>
          </section>
          <aside class="image-pane">
            <!-- osd-facsimile.js mounts OpenSeadragon here and draws the zones -->
            <div class="facsimile" data-iiif="{$iiifData}">
              <script type="application/json" class="facsimile-zones">
                <xsl:text>[</xsl:text>
                <xsl:for-each select="//tei:facsimile//tei:zone">
                  <xsl:if test="position() &gt; 1"><xsl:text>,</xsl:text></xsl:if>
                  <xsl:variable name="zid" select="@*[local-name()='id']"/>
                  <xsl:text>{"x":</xsl:text><xsl:value-of select="number(@ulx)"/>
                  <xsl:text>,"y":</xsl:text><xsl:value-of select="number(@uly)"/>
                  <xsl:text>,"w":</xsl:text>
                  <xsl:value-of select="number(@lrx) - number(@ulx)"/>
                  <xsl:text>,"h":</xsl:text>
                  <xsl:value-of select="number(@lry) - number(@uly)"/>
                  <xsl:text>,"type":"</xsl:text>
                  <xsl:value-of select="@type"/><xsl:text>"</xsl:text>
                  <xsl:choose>
                    <xsl:when test="@type='deed'">
                      <xsl:variable name="dn"
                          select="substring-after($zid, 'zone-I-')"/>
                      <xsl:text>,"label":"Deed </xsl:text>
                      <xsl:value-of select="$dn"/><xsl:text>"</xsl:text>
                      <xsl:text>,"target":"deed-</xsl:text>
                      <xsl:value-of select="$dn"/><xsl:text>"}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>,"label":"</xsl:text>
                      <xsl:value-of select="$zid"/><xsl:text>"}</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
                <xsl:text>]</xsl:text>
              </script>
            </div>
          </aside>
        </div>

        <!-- ===== teiHeader data for tei-header.js (built into the top bar) ===== -->
        <div class="tei-header" hidden="hidden" data-title="{$title}">
          <button type="button" class="tei-extra" data-zone-toggle="">ゾーン表示</button>

          <section class="tei-panel" data-label="概要 / Overview">
            <dl class="kv">
              <xsl:if test="//tei:titleStmt/tei:title[@type='sub']">
                <dt>副題 / Subtitle</dt>
                <dd><xsl:value-of select="normalize-space(//tei:titleStmt/tei:title[@type='sub'])"/></dd>
              </xsl:if>
              <xsl:if test="//tei:titleStmt/tei:editor">
                <dt>編者 / Editors</dt>
                <dd>
                  <xsl:for-each select="//tei:titleStmt/tei:editor">
                    <xsl:if test="position() &gt; 1"><xsl:text>; </xsl:text></xsl:if>
                    <xsl:value-of select="normalize-space(.)"/>
                  </xsl:for-each>
                </dd>
              </xsl:if>
              <xsl:if test="//tei:history/tei:origin">
                <dt>来歴 / Origin</dt>
                <dd>
                  <xsl:value-of select="normalize-space(//tei:history/tei:origin/tei:origPlace)"/>
                  <xsl:for-each select="//tei:history/tei:origin/tei:origDate">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(.)"/>
                  </xsl:for-each>
                </dd>
              </xsl:if>
              <dt>証文数 / Deeds</dt>
              <dd><xsl:value-of select="count(//tei:body/tei:div[@type='deed'])"/></dd>
            </dl>
            <xsl:if test="//tei:msContents/tei:summary">
              <h3>要約 / Summary</h3>
              <p><xsl:value-of select="normalize-space(//tei:msContents/tei:summary)"/></p>
            </xsl:if>
          </section>

          <section class="tei-panel" data-label="写本記述 / MS Description">
            <dl class="kv">
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'国 / Country'"/>
                <xsl:with-param name="value" select="//tei:msIdentifier/tei:country"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'所在地 / Settlement'"/>
                <xsl:with-param name="value" select="//tei:msIdentifier/tei:settlement"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'所蔵 / Repository'"/>
                <xsl:with-param name="value" select="//tei:msIdentifier/tei:repository"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'整理番号 / Shelfmark'"/>
                <xsl:with-param name="value" select="//tei:msIdentifier/tei:idno"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'コレクション / Collection'"/>
                <xsl:with-param name="value" select="//tei:altIdentifier/tei:idno"/>
              </xsl:call-template>
              <xsl:if test="//tei:supportDesc/tei:support">
                <dt>素材 / Support</dt>
                <dd>
                  <xsl:value-of select="normalize-space(//tei:supportDesc/tei:support)"/>
                  <xsl:if test="//tei:dimensions">
                    <xsl:text> — </xsl:text>
                    <xsl:value-of select="normalize-space(//tei:dimensions/tei:height)"/>
                    <xsl:text> &#215; </xsl:text>
                    <xsl:value-of select="normalize-space(//tei:dimensions/tei:width)"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="//tei:dimensions/@unit"/>
                  </xsl:if>
                </dd>
              </xsl:if>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'言語 / Language'"/>
                <xsl:with-param name="value" select="//tei:msContents/tei:textLang"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'来歴 / Provenance'"/>
                <xsl:with-param name="value" select="//tei:history/tei:provenance"/>
              </xsl:call-template>
            </dl>
          </section>

          <section class="tei-panel" data-label="書誌 / Bibliography">
            <xsl:choose>
              <xsl:when test="//tei:listBibl/tei:bibl">
                <xsl:for-each select="//tei:listBibl/tei:bibl">
                  <p class="tei-bibl">
                    <xsl:for-each select="tei:editor">
                      <xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
                      <xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                    <xsl:text>. </xsl:text>
                    <em><xsl:value-of select="normalize-space(tei:title[@level='m'])"/></em>
                    <xsl:if test="tei:series">
                      <xsl:text> (</xsl:text>
                      <xsl:value-of select="normalize-space(tei:series/tei:title)"/>
                      <xsl:if test="tei:series/tei:biblScope">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(tei:series/tei:biblScope)"/>
                      </xsl:if>
                      <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="normalize-space(tei:pubPlace)"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="normalize-space(tei:publisher)"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(tei:date)"/>
                    <xsl:text>.</xsl:text>
                  </p>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise><p>（書誌情報なし）</p></xsl:otherwise>
            </xsl:choose>
          </section>

          <section class="tei-panel" data-label="プロジェクト / Project">
            <dl class="kv">
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'版 / Edition'"/>
                <xsl:with-param name="value" select="//tei:editionStmt/tei:edition"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'出版 / Publisher'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:publisher"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'出版地 / Place'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:pubPlace"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'出版年 / Date'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:date"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'助成 / Funder'"/>
                <xsl:with-param name="value" select="//tei:titleStmt/tei:funder"/>
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
            <xsl:if test="//tei:projectDesc">
              <h3>プロジェクト概要 / Project description</h3>
              <p><xsl:value-of select="normalize-space(//tei:projectDesc)"/></p>
            </xsl:if>
            <xsl:if test="//tei:editorialDecl">
              <h3>校訂方針 / Editorial declaration</h3>
              <p><xsl:value-of select="normalize-space(//tei:editorialDecl)"/></p>
            </xsl:if>
            <xsl:if test="//tei:revisionDesc/tei:change">
              <h3>改訂履歴 / Revisions</h3>
              <xsl:for-each select="//tei:revisionDesc/tei:change">
                <p>
                  <xsl:if test="@when">
                    <strong><xsl:value-of select="@when"/></strong>
                    <xsl:text> — </xsl:text>
                  </xsl:if>
                  <xsl:value-of select="normalize-space(.)"/>
                </p>
              </xsl:for-each>
            </xsl:if>
          </section>
        </div>

        <script src="js/shared/tei-header.js"></script>
        <script src="js/shared/osd-facsimile.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- ====== Deed ====== -->
  <xsl:template match="tei:div[@type='deed']">
    <article class="deed" id="deed-{@n}">
      <h3 class="deed-h">
        <xsl:text>証文 </xsl:text><xsl:value-of select="@n"/>
        <xsl:text> / Deed </xsl:text><xsl:value-of select="@n"/>
      </h3>
      <div class="deed-text" dir="rtl" lang="ar">
        <xsl:apply-templates/>
      </div>
      <xsl:if test=".//tei:note">
        <ol class="deed-notes">
          <xsl:for-each select=".//tei:note">
            <li>
              <span class="fn-no">[<xsl:value-of select="@n"/>]</span>
              <xsl:text> </xsl:text>
              <xsl:value-of select="normalize-space(.)"/>
            </li>
          </xsl:for-each>
        </ol>
      </xsl:if>
    </article>
  </xsl:template>

  <!-- ====== Inline elements within a deed ====== -->
  <xsl:template match="tei:lb"><br/></xsl:template>

  <xsl:template match="tei:ab">
    <span class="nass"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:seg[@rend='underline']">
    <span class="nass-label"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:seg[@type='sigil']">
    <span class="sigil"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:seg"><span><xsl:apply-templates/></span></xsl:template>

  <!-- footnote: inline marker only; full text is collected per deed above -->
  <xsl:template match="tei:note">
    <sup class="note-ref">[<xsl:value-of select="@n"/>]</sup>
  </xsl:template>

  <xsl:template match="tei:hi"><xsl:apply-templates/></xsl:template>

  <!-- ====== Helper: one key/value row, skipped when empty ====== -->
  <xsl:template name="kv">
    <xsl:param name="label"/>
    <xsl:param name="value"/>
    <xsl:if test="normalize-space($value) != ''">
      <dt><xsl:value-of select="$label"/></dt>
      <dd><xsl:value-of select="normalize-space($value)"/></dd>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
