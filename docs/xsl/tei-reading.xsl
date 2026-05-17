<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-reading.xsl — Reading view / 本文リーディングビュー

  Title:       Reading view / 本文リーディングビュー
  Description: TEI 本文を、見出し・段落・リスト・表・強調・注として読みやすい HTML に整形する完結したスタイルシート。/ Renders the TEI body as readable HTML with headings, paragraphs, lists, tables and notes.
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
        <title><xsl:value-of select="$title"/></title>
        <style>
          body { font-family: Georgia, "Times New Roman", serif; line-height: 1.75;
                 color: #1a1a1a; background: #fff; margin: 0; }
          /* 本文の余白はラッパーに持たせる。body 直下の共有ヘッダーバー
             (js/shared/tei-header.js) を端まで広げるため。 */
          .doc { padding: 2rem clamp(1rem, 5vw, 4rem); }
          .doc-title { font-size: 1.7rem; margin: 0 0 1.5rem; line-height: 1.3; }
          h2 { font-size: 1.3rem; margin: 1.8em 0 .5em; }
          h3 { font-size: 1.12rem; margin: 1.4em 0 .4em; }
          h4 { font-size: 1rem; margin: 1.2em 0 .4em; }
          p { margin: .7em 0; text-align: justify; }
          ul, ol { margin: .7em 0 .7em 1.6em; }
          li { margin: .3em 0; }
          table { border-collapse: collapse; width: 100%; margin: 1.2em 0;
                  font-size: .95rem; }
          th, td { border: 1px solid #ccc; padding: .5em .7em;
                   text-align: left; vertical-align: top; }
          th { background: #f3f3f3; }
          .note-ref { color: #1a6cff; font-size: .72em; cursor: help;
                      vertical-align: super; }
          section { margin-bottom: .5em; }
        </style>
      </head>
      <body>
        <main class="doc">
          <xsl:apply-templates select="//tei:text/tei:front//tei:titlePart"/>
          <xsl:apply-templates select="//tei:text/tei:body"/>
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

  <xsl:template match="tei:titlePart">
    <h1 class="doc-title"><xsl:apply-templates/></h1>
  </xsl:template>

  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:div">
    <section class="tei-div"><xsl:apply-templates/></section>
  </xsl:template>

  <!-- 見出しは div のネストの深さに応じて h2〜h4 を割り当てる -->
  <xsl:template match="tei:head">
    <xsl:variable name="depth" select="count(ancestor::tei:div)"/>
    <xsl:choose>
      <xsl:when test="$depth &lt;= 1"><h2><xsl:apply-templates/></h2></xsl:when>
      <xsl:when test="$depth = 2"><h3><xsl:apply-templates/></h3></xsl:when>
      <xsl:otherwise><h4><xsl:apply-templates/></h4></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:p">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="tei:list[@rend='numbered']">
    <ol><xsl:apply-templates select="tei:item"/></ol>
  </xsl:template>

  <xsl:template match="tei:list">
    <ul><xsl:apply-templates select="tei:item"/></ul>
  </xsl:template>

  <xsl:template match="tei:item">
    <li><xsl:apply-templates/></li>
  </xsl:template>

  <xsl:template match="tei:table">
    <table><xsl:apply-templates select="tei:row"/></table>
  </xsl:template>

  <xsl:template match="tei:row">
    <tr><xsl:apply-templates select="tei:cell"/></tr>
  </xsl:template>

  <xsl:template match="tei:cell">
    <td><xsl:apply-templates/></td>
  </xsl:template>

  <!-- @rend の値の組み合わせで強調を表現する。単一テンプレート + xsl:choose に
       することで、複数パターンが同時に一致したときの優先順位の曖昧さを避ける。 -->
  <xsl:template match="tei:hi">
    <xsl:choose>
      <xsl:when test="contains(@rend,'bold') and contains(@rend,'italic')">
        <strong><em><xsl:apply-templates/></em></strong>
      </xsl:when>
      <xsl:when test="contains(@rend,'bold')">
        <strong><xsl:apply-templates/></strong>
      </xsl:when>
      <xsl:when test="contains(@rend,'italic')">
        <em><xsl:apply-templates/></em>
      </xsl:when>
      <xsl:when test="contains(@rend,'underline')">
        <u><xsl:apply-templates/></u>
      </xsl:when>
      <xsl:otherwise>
        <span class="hi"><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 注は番号付きの上付き文字にし、本文は title 属性（ツールチップ）に格納 -->
  <xsl:template match="tei:note">
    <sup class="note-ref" title="{normalize-space(.)}">
      <xsl:text>[</xsl:text>
      <xsl:choose>
        <xsl:when test="@n"><xsl:value-of select="@n"/></xsl:when>
        <xsl:otherwise><xsl:text>*</xsl:text></xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
    </sup>
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
