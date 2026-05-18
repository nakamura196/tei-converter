<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-analysis.xsl — Tag statistics / タグ統計・可視化

  Title:       Tag statistics / タグ統計・可視化
  Description: 文書中の全要素・全属性を名前ごとに集計し、出現頻度を棒グラフ（HTML/CSS のみ）で可視化します。どんな TEI/XML にも適用できる構造分析ビューです。/ Counts every element and attribute by name and visualizes the frequencies as bar charts (pure HTML/CSS). A structure-analysis view that works with any TEI/XML.
  Category:    汎用 / General-purpose
  License:     自由に利用・改変できます（XSLT 1.0）。/ Free to use and adapt (XSLT 1.0).
  Sample:      xml/tei-guide/tei.xml

  どんな TEI/XML にも適用できる汎用の分析スタイルシート。特定のタグ構造を
  前提とせず、文書を走査して統計を出す:
    * 要約 … 要素総数 / 要素の種類数 / 属性総数 / 属性の種類数 /
             最大ネスト深さ / テキスト総文字数
    * 要素の出現頻度 … 要素名（local-name）ごとの件数を降順の棒グラフに
    * 属性の出現頻度 … 属性名ごとの件数を降順の棒グラフに

  集計は名前空間を無視し local-name() で行う（tei: 接頭辞の有無に依存しない）。
  グラフは外部ライブラリを使わず HTML/CSS のみ。共有ヘッダー
  (js/shared/tei-header.js) に teiHeader 情報を渡す。
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

  <xsl:output method="html" encoding="UTF-8" indent="yes"
      doctype-system="about:legacy-compat"/>

  <xsl:key name="el" match="*"  use="local-name()"/>
  <xsl:key name="at" match="@*" use="local-name()"/>

  <xsl:variable name="title" select="normalize-space(//tei:titleStmt/tei:title)"/>

  <!-- 名前ごとに最初の 1 件だけを残した要素／属性のノード集合 -->
  <xsl:variable name="elFirst"
      select="//*[generate-id() = generate-id(key('el', local-name())[1])]"/>
  <xsl:variable name="atFirst"
      select="//@*[generate-id() = generate-id(key('at', local-name())[1])]"/>

  <!-- 棒グラフのスケール用：最頻の件数 -->
  <xsl:variable name="elMax">
    <xsl:for-each select="$elFirst">
      <xsl:sort select="count(key('el', local-name()))" data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="count(key('el', local-name()))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="atMax">
    <xsl:for-each select="$atFirst">
      <xsl:sort select="count(key('at', local-name()))" data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="count(key('at', local-name()))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <!-- 最大ネスト深さ -->
  <xsl:variable name="depth">
    <xsl:for-each select="//*">
      <xsl:sort select="count(ancestor-or-self::*)" data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="count(ancestor-or-self::*)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>タグ統計 — <xsl:value-of select="$title"/></title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
                 line-height: 1.7; color: #1a1a1a; background: #fff; margin: 0; }
          .doc { padding: 2rem clamp(1rem, 5vw, 4rem); }
          h1 { font-size: 1.5rem; margin: 0 0 .3rem; }
          h2 { font-size: 1.1rem; margin: 2.2rem 0 .9rem;
               border-bottom: 2px solid #e3e3e3; padding-bottom: .3rem; }
          .doc-sub { color: #666; font-size: .9rem; margin: 0 0 1.5rem; }

          /* 要約カード */
          .cards { display: grid; gap: .8rem; margin: 1.2rem 0 .5rem;
                   grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
          .card { background: #f7f8fa; border: 1px solid #e3e3e3; border-radius: 8px;
                  padding: .9rem 1rem; }
          .card-num { font-size: 1.7rem; font-weight: 700; color: #2563eb;
                      font-variant-numeric: tabular-nums; line-height: 1.2; }
          .card-label { font-size: .78rem; color: #666; margin-top: .15rem; }

          /* 棒グラフ */
          .chart { margin: .5rem 0 1rem; }
          .bar-row { display: grid; grid-template-columns: 13rem 1fr 4rem;
                     align-items: center; gap: .6rem; padding: .15rem 0; }
          .bar-label { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace;
                       font-size: .85rem; color: #1a1a1a; text-align: right;
                       overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
          .bar-track { background: #eef0f3; border-radius: 4px; height: 1.15rem; }
          .bar-fill { display: block; height: 100%; min-width: 2px; border-radius: 4px;
                      background: linear-gradient(90deg, #3b82f6, #2563eb); }
          .bar-val { font-size: .85rem; color: #444; text-align: right;
                     font-variant-numeric: tabular-nums; }
          .bar-pct { color: #999; font-size: .72rem; }
          .empty { color: #bbb; }
          @media (max-width: 560px) {
            .bar-row { grid-template-columns: 7.5rem 1fr 3.2rem; }
          }
        </style>
      </head>
      <body>
        <main class="doc">
          <h1>タグ統計・可視化 / Tag statistics</h1>
          <p class="doc-sub"><xsl:value-of select="$title"/></p>

          <xsl:choose>
            <xsl:when test="count(//*) = 0">
              <p class="empty">分析できる要素がありません。 / No elements to analyze.</p>
            </xsl:when>
            <xsl:otherwise>
              <!-- 要約カード -->
              <div class="cards">
                <xsl:call-template name="card">
                  <xsl:with-param name="num" select="count(//*)"/>
                  <xsl:with-param name="label" select="'要素総数 / Elements'"/>
                </xsl:call-template>
                <xsl:call-template name="card">
                  <xsl:with-param name="num" select="count($elFirst)"/>
                  <xsl:with-param name="label" select="'要素の種類 / Element types'"/>
                </xsl:call-template>
                <xsl:call-template name="card">
                  <xsl:with-param name="num" select="count(//@*)"/>
                  <xsl:with-param name="label" select="'属性総数 / Attributes'"/>
                </xsl:call-template>
                <xsl:call-template name="card">
                  <xsl:with-param name="num" select="count($atFirst)"/>
                  <xsl:with-param name="label" select="'属性の種類 / Attribute types'"/>
                </xsl:call-template>
                <xsl:call-template name="card">
                  <xsl:with-param name="num" select="$depth"/>
                  <xsl:with-param name="label" select="'最大ネスト深さ / Max depth'"/>
                </xsl:call-template>
                <xsl:call-template name="card">
                  <xsl:with-param name="num" select="string-length(normalize-space(/))"/>
                  <xsl:with-param name="label" select="'テキスト文字数 / Text length'"/>
                </xsl:call-template>
              </div>

              <!-- 要素の出現頻度 -->
              <h2>要素の出現頻度 / Element frequency</h2>
              <div class="chart">
                <xsl:for-each select="$elFirst">
                  <xsl:sort select="count(key('el', local-name()))"
                            data-type="number" order="descending"/>
                  <xsl:sort select="local-name()"/>
                  <xsl:call-template name="bar">
                    <xsl:with-param name="name"  select="local-name()"/>
                    <xsl:with-param name="count" select="count(key('el', local-name()))"/>
                    <xsl:with-param name="max"   select="$elMax"/>
                    <xsl:with-param name="total" select="count(//*)"/>
                  </xsl:call-template>
                </xsl:for-each>
              </div>

              <!-- 属性の出現頻度 -->
              <h2>属性の出現頻度 / Attribute frequency</h2>
              <xsl:choose>
                <xsl:when test="count(//@*) = 0">
                  <p class="empty">属性がありません。 / No attributes.</p>
                </xsl:when>
                <xsl:otherwise>
                  <div class="chart">
                    <xsl:for-each select="$atFirst">
                      <xsl:sort select="count(key('at', local-name()))"
                                data-type="number" order="descending"/>
                      <xsl:sort select="local-name()"/>
                      <xsl:call-template name="bar">
                        <xsl:with-param name="name"  select="concat('@', local-name())"/>
                        <xsl:with-param name="count" select="count(key('at', local-name()))"/>
                        <xsl:with-param name="max"   select="$atMax"/>
                        <xsl:with-param name="total" select="count(//@*)"/>
                      </xsl:call-template>
                    </xsl:for-each>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
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
          </section>
        </div>
        <script src="js/shared/tei-header.js"></script>
      </body>
    </html>
  </xsl:template>

  <!-- 要約カード 1 枚 -->
  <xsl:template name="card">
    <xsl:param name="num"/>
    <xsl:param name="label"/>
    <div class="card">
      <div class="card-num"><xsl:value-of select="$num"/></div>
      <div class="card-label"><xsl:value-of select="$label"/></div>
    </div>
  </xsl:template>

  <!-- 棒グラフ 1 行：name / バー / 件数（全体に対する % 付き） -->
  <xsl:template name="bar">
    <xsl:param name="name"/>
    <xsl:param name="count"/>
    <xsl:param name="max"/>
    <xsl:param name="total"/>
    <div class="bar-row">
      <span class="bar-label" title="{$name}"><xsl:value-of select="$name"/></span>
      <span class="bar-track">
        <span class="bar-fill"
              style="width:{format-number($count div $max * 100, '0.#')}%"></span>
      </span>
      <span class="bar-val">
        <xsl:value-of select="$count"/>
        <xsl:text> </xsl:text>
        <span class="bar-pct">
          <xsl:value-of select="format-number($count div $total, '0.0%')"/>
        </span>
      </span>
    </div>
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
