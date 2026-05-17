<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-notes.xsl — Notes list / 注釈一覧

  Title:       Notes list / 注釈一覧
  Description: 文書中の note 要素をすべて抽出し、種別・内容の一覧表にまとめます。/ Extracts every note element into a single table of place and content.
  Category:    汎用 / General-purpose
  License:     自由に利用・改変できます（XSLT 1.0）。/ Free to use and adapt (XSLT 1.0).
  Sample:      xml/tei-guide/tei.xml
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
      doctype-system="about:legacy-compat"/>

  <xsl:variable name="title" select="normalize-space(//tei:titleStmt/tei:title)"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>注釈一覧 — <xsl:value-of select="$title"/></title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
                 line-height: 1.7; color: #1a1a1a; background: #fff; margin: 0; }
          /* 本文の余白はラッパーに持たせる。body 直下の共有ヘッダーバー
             (js/shared/tei-header.js) を端まで広げるため。 */
          .doc { padding: 2rem clamp(1rem, 5vw, 4rem); }
          h1 { font-size: 1.5rem; margin: 0 0 .3rem; }
          .doc-sub { color: #666; font-size: .9rem; margin: 0 0 1.5rem; }
          .note-count { color: #666; font-size: .85rem; margin: 0 0 1rem; }
          table { border-collapse: collapse; width: 100%; font-size: .95rem; }
          th, td { border: 1px solid #ccc; padding: .5em .7em;
                   text-align: left; vertical-align: top; }
          th { background: #f3f3f3; }
          td.num { text-align: center; white-space: nowrap; color: #555;
                   font-variant-numeric: tabular-nums; }
          .empty { color: #bbb; }
        </style>
      </head>
      <body>
        <main class="doc">
        <h1>注釈一覧 / Notes</h1>
        <p class="doc-sub"><xsl:value-of select="$title"/></p>
        <xsl:variable name="notes" select="//tei:note"/>
        <xsl:choose>
          <xsl:when test="$notes">
            <p class="note-count">
              <xsl:value-of select="count($notes)"/>
              <xsl:text> 件の注釈が見つかりました / notes found</xsl:text>
            </p>
            <table>
              <tr>
                <th>No.</th>
                <th>種別 / Place</th>
                <th>内容 / Content</th>
              </tr>
              <xsl:for-each select="$notes">
                <tr>
                  <td class="num">
                    <xsl:choose>
                      <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
                      <xsl:otherwise><xsl:value-of select="position()"/></xsl:otherwise>
                    </xsl:choose>
                  </td>
                  <td>
                    <xsl:choose>
                      <xsl:when test="@place"><xsl:value-of select="@place"/></xsl:when>
                      <xsl:otherwise><span class="empty">—</span></xsl:otherwise>
                    </xsl:choose>
                  </td>
                  <td><xsl:value-of select="normalize-space(.)"/></td>
                </tr>
              </xsl:for-each>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <p class="empty">この文書には &lt;note&gt; 要素がありません。 / No &lt;note&gt; elements in this document.</p>
          </xsl:otherwise>
        </xsl:choose>
        </main>
        <!-- teiHeader データ（共有ヘッダー: js/shared/tei-header.js が上部バーを生成） -->
        <div class="tei-header" hidden="hidden" data-title="{$title}">
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
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'編者 / Editor'"/>
                <xsl:with-param name="value" select="//tei:titleStmt/tei:editor"/>
              </xsl:call-template>
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
                <xsl:with-param name="label" select="'言語 / Language'"/>
                <xsl:with-param name="value" select="//tei:langUsage/tei:language"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'原資料 / Source'"/>
                <xsl:with-param name="value" select="//tei:sourceDesc/tei:bibl | //tei:sourceDesc/tei:p"/>
              </xsl:call-template>
            </dl>
          </section>
        </div>
        <script src="js/shared/tei-header.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- teiHeader パネル用: ラベルと値の行（空なら省略・複数値は ; 連結） -->
  <xsl:template name="kv">
    <xsl:param name="label"/>
    <xsl:param name="value"/>
    <xsl:if test="$value[normalize-space(.) != '']">
      <dt><xsl:value-of select="$label"/></dt>
      <dd>
        <xsl:for-each select="$value">
          <xsl:if test="position() &gt; 1"><xsl:text>; </xsl:text></xsl:if>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:for-each>
      </dd>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
