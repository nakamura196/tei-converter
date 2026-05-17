<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-bibliography.xsl — Bibliography table / 書誌情報テーブル

  Title:       Bibliography table / 書誌情報テーブル
  Description: teiHeader からタイトル・著者・出版情報・改訂履歴などのメタデータを抽出し、表にまとめます。/ Pulls title, author, publication details and revision history out of the teiHeader.
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
        <title>書誌情報 — <xsl:value-of select="$title"/></title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
                 line-height: 1.7; color: #1a1a1a; background: #fff; margin: 0; }
          /* 本文の余白はラッパーに持たせる。body 直下の共有ヘッダーバー
             (js/shared/tei-header.js) を端まで広げるため。 */
          .doc { padding: 2rem clamp(1rem, 5vw, 4rem); }
          h1 { font-size: 1.5rem; margin: 0 0 1.5rem; }
          table { border-collapse: collapse; width: 100%; font-size: .95rem; }
          th, td { border: 1px solid #ccc; padding: .5em .7em;
                   text-align: left; vertical-align: top; }
          th { background: #f3f3f3; }
          td.field { font-weight: 600; white-space: nowrap; background: #fafafa; }
          ul.rev-list { margin: 0; padding-left: 1.2em; }
          .empty { color: #bbb; }
        </style>
      </head>
      <body>
        <main class="doc">
        <h1>書誌情報 / Bibliographic Information</h1>
        <table>
          <tr><th>項目 / Field</th><th>値 / Value</th></tr>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'タイトル / Title'"/>
            <xsl:with-param name="nodes" select="//tei:titleStmt/tei:title"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'著者 / Author'"/>
            <xsl:with-param name="nodes" select="//tei:titleStmt/tei:author"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'編者 / Editor'"/>
            <xsl:with-param name="nodes" select="//tei:titleStmt/tei:editor"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'版 / Edition'"/>
            <xsl:with-param name="nodes" select="//tei:editionStmt/tei:edition"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'出版者 / Publisher'"/>
            <xsl:with-param name="nodes" select="//tei:publicationStmt/tei:publisher"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'出版地 / Place'"/>
            <xsl:with-param name="nodes" select="//tei:publicationStmt/tei:pubPlace"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'出版年 / Date'"/>
            <xsl:with-param name="nodes" select="//tei:publicationStmt/tei:date"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'言語 / Language'"/>
            <xsl:with-param name="nodes" select="//tei:langUsage/tei:language"/>
          </xsl:call-template>
          <xsl:call-template name="row">
            <xsl:with-param name="label" select="'原資料 / Source'"/>
            <xsl:with-param name="nodes" select="//tei:sourceDesc/tei:bibl | //tei:sourceDesc/tei:p"/>
          </xsl:call-template>
          <tr>
            <td class="field">改訂履歴 / Revisions</td>
            <td>
              <xsl:choose>
                <xsl:when test="//tei:revisionDesc//tei:change">
                  <ul class="rev-list">
                    <xsl:for-each select="//tei:revisionDesc//tei:change">
                      <li>
                        <xsl:if test="@when">
                          <strong><xsl:value-of select="@when"/></strong>
                          <xsl:text> — </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)"/>
                      </li>
                    </xsl:for-each>
                  </ul>
                </xsl:when>
                <xsl:otherwise><span class="empty">—</span></xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </table>
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
                <xsl:with-param name="label" select="'出版 / Publisher'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:publisher"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'出版年 / Date'"/>
                <xsl:with-param name="value" select="//tei:publicationStmt/tei:date"/>
              </xsl:call-template>
              <xsl:call-template name="kv">
                <xsl:with-param name="label" select="'言語 / Language'"/>
                <xsl:with-param name="value" select="//tei:langUsage/tei:language"/>
              </xsl:call-template>
            </dl>
            <p style="font-size:.82rem;color:#888;margin-top:.8rem">
              詳細は本文の表を参照してください。 / See the table below for full detail.
            </p>
          </section>
        </div>
        <script src="js/shared/tei-header.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- ラベルと節集合を 1 行にする。複数値は ; で連結。値が無ければ — を表示 -->
  <xsl:template name="row">
    <xsl:param name="label"/>
    <xsl:param name="nodes"/>
    <tr>
      <td class="field"><xsl:value-of select="$label"/></td>
      <td>
        <xsl:choose>
          <xsl:when test="$nodes[normalize-space(.) != '']">
            <xsl:for-each select="$nodes">
              <xsl:if test="position() &gt; 1"><xsl:text>; </xsl:text></xsl:if>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise><span class="empty">—</span></xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
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
