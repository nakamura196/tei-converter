<?xml version="1.0" encoding="UTF-8"?>
<!--
  tei-manchu.xsl — 清語老乞大 縦書きビュー / Cing gisun-i Lao Kida vertical view

  Title:       清語老乞大 縦書きビュー / Cing gisun-i Lao Kida vertical view
  Description: 朝鮮司譯院刊『清語老乞大』巻之一・第一葉表の TEI 専用。影印画像と、満州文字（縦書き）＋ハングル音注＋割書諺解を再現した HTML 版面を左右に並べて表示します。/ Dedicated to the "Cing gisun-i Lao Kida" (Korean Saiyŏgwŏn edition, vol. 1, fol. 1a): the facsimile image beside an HTML reproduction of the vertical Manchu script with Hangul phonetic glosses and the interlinear Korean translation.
  Category:    プロジェクト専用 / Project-specific
  License:     自由に利用・改変できます（XSLT 1.0）。/ Free to use and adapt (XSLT 1.0).
  Sample:      xml/manchu/tei.xml

  「清語老乞大」（朝鮮司譯院刊・満州語会話教本）の版面再現用スタイルシート。

  この TEI の独自構造:
    * facsimile/surface/graphic … 影印画像
    * text/body/head … 題簽（書名・巻次）
    * cb … 印刷上の段（列）の境界。文の途中での改列も表現する
    * w[@xml:lang='mnc-Mong'] … 満州語の各語（満州文字本体）
    * w/note[@type='phon'][@place='marginRight'] … 各語右側のハングル音注
    * note[@type='warigaki'] … 中世韓国語訳の割書（lb で 2 行に分割）

  出力レイアウト（完結した HTML 文書、XSLT 1.0）:
    * 左に影印画像、右に XSLT で再現した縦書き版面の 2 列並列。
    * 満州文字は CSS の writing-mode による縦書き。Noto Sans Mongolian
      フォントを Google Fonts から読み込む。
    * 共有 JS は使わず、この XSL だけで完結する。画像は <graphic url> を
      参照する（ギャラリー / view.html 側で絶対 URL に解決される）。
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="tei">

  <xsl:output method="html"
              encoding="UTF-8"
              indent="yes"
              doctype-system="about:legacy-compat"/>

  <xsl:variable name="all-cbs" select="//tei:cb"/>

  <xsl:template match="/tei:TEI">
    <html lang="ja">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>清語老乞大 卷之一 — TEI/XSLT による満州文字版面の再現</title>
        <meta name="description" content="朝鮮司譯院刊『清語老乞大』巻之一・第一葉表を題材に、TEI/XML 符号化と XSLT による縦書き版面（満州文字＋ハングル音注＋諺解の割書）の再現を行った学術用デモ。"/>
        <meta name="author" content="Satoru Nakamura"/>

        <link rel="preconnect" href="https://fonts.googleapis.com"/>
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
        <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Mongolian&amp;family=Noto+Serif+KR:wght@400;700&amp;display=swap" rel="stylesheet"/>
        <style>
          :root {
            --paper: #efe3c7;
            --paper-edge: #d4c39a;
            --ink: #1a1a1a;
            --rule: #1a1a1a;
            --frame: #1a1a1a;
          }
          * { box-sizing: border-box; }
          body {
            margin: 0;
            background: #2b2018;
            color: var(--ink);
            font-family: "Hiragino Mincho ProN", "Yu Mincho", serif;
          }
          header.bar {
            background: #1a120c;
            color: #efe3c7;
            padding: .8rem 1rem;
            font-size: .85rem;
          }
          .stage {
            padding: 1.4rem 1rem 1.4rem;
            overflow-x: auto;
          }
          .compare {
            display: flex;
            flex-direction: row;
            gap: 1.4rem;
            align-items: flex-start;
            flex-wrap: nowrap;
            width: 100%;
            max-width: 1500px;
            margin: 0 auto;
          }
          .panel { display: flex; flex-direction: column; align-items: center; }
          .panel.facsimile, .panel.recon { flex: 0 0 auto; }
          .panel-label {
            color: #efe3c7;
            font-size: .82rem;
            margin: 0 0 .5rem;
            letter-spacing: .1em;
          }
          .panel-label small {
            display: block;
            opacity: .65;
            font-size: .68rem;
            margin-top: .15rem;
            font-weight: normal;
            letter-spacing: 0;
          }
          .facsimile-frame {
            background: #efe3c7;
            border: 4px double var(--frame);
            box-shadow: 0 4px 14px rgba(0,0,0,.55);
            padding: 8px;
          }
          .facsimile-frame img {
            display: block;
            height: 720px;
            width: auto;
            max-width: 100%;
          }
          .page {
            background: var(--paper);
            background-image:
              repeating-linear-gradient(0deg,
                rgba(0,0,0,0.012) 0,
                rgba(0,0,0,0.012) 2px,
                transparent 2px,
                transparent 5px);
            border: 4px double var(--frame);
            box-shadow: 0 4px 14px rgba(0,0,0,.55), inset 0 0 0 1px var(--paper-edge);
            padding: 1.4rem 1.2rem;
            display: flex;
            flex-direction: row;
            align-items: stretch;
            gap: 0;
            height: 720px;
          }
          .col {
            border-left: 1px solid var(--rule);
            padding: .4rem .55rem;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            min-width: 2.6rem;
          }
          .col.title-col {
            min-width: 3.2rem;
            justify-content: flex-start;
            padding-top: .8rem;
          }
          .title-cn {
            writing-mode: vertical-rl;
            font-family: "Songti SC", "STSong", "SimSun", "Noto Serif TC", serif;
            font-size: 2.1rem;
            font-weight: 700;
            letter-spacing: .25rem;
            color: var(--ink);
          }
          .title-vol {
            writing-mode: vertical-rl;
            font-family: "Songti SC", "STSong", "SimSun", serif;
            font-size: 1.05rem;
            margin-top: 1rem;
            letter-spacing: .15rem;
          }
          .col.manchu-col {
            min-width: 3.6rem;
            padding: .4rem .4rem .4rem .4rem;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
          }
          .word {
            display: flex;
            flex-direction: row;
            align-items: stretch;
            gap: .08rem;
          }
          .m-text {
            writing-mode: vertical-lr;
            -webkit-writing-mode: vertical-lr;
            text-orientation: mixed;
            -webkit-text-orientation: mixed;
            font-family: "Noto Sans Mongolian", "Mongolian Baiti", serif;
            font-size: 22px;
            line-height: 1.05;
            letter-spacing: 0;
            color: var(--ink);
            white-space: nowrap;
            flex: none;
            display: inline-block;
            min-width: 1.6em;
            text-align: start;
          }
          .m-pron {
            writing-mode: vertical-lr;
            -webkit-writing-mode: vertical-lr;
            font-family: "Noto Serif KR", "AppleSDGothicNeo-Regular", "Apple SD Gothic Neo", "Malgun Gothic", serif;
            font-size: .68rem;
            line-height: 1.05;
            letter-spacing: .02em;
            color: var(--ink);
            opacity: .92;
            white-space: nowrap;
            align-self: flex-start;
            padding-top: .15rem;
          }
          .warigaki {
            display: flex;
            flex-direction: row;
            align-items: flex-start;
            margin: .15rem 0;
            gap: .05rem;
          }
          .wari-line {
            writing-mode: vertical-lr;
            -webkit-writing-mode: vertical-lr;
            font-family: "Noto Serif KR", "AppleSDGothicNeo-Regular", "Apple SD Gothic Neo", "Malgun Gothic", serif;
            font-size: .72rem;
            line-height: 1.1;
            letter-spacing: .02em;
            color: var(--ink);
            white-space: nowrap;
            flex: 1;
            text-align: start;
          }
          aside.legend {
            max-width: 1500px;
            margin: 0 auto 1.4rem;
            padding: 1rem 1.2rem;
            background: rgba(239,227,199,0.92);
            border-radius: 4px;
            font-size: .82rem;
            line-height: 1.7;
            color: #2b2018;
          }
          aside.legend h2 {
            margin: 0 0 .4rem;
            font-size: .95rem;
            color: #5a2a1a;
          }
          aside.legend dt {
            display: inline-block;
            min-width: 9rem;
            font-weight: bold;
          }
          aside.legend dd { display: inline; margin: 0; }
          aside.legend dd::after { content: ""; display: block; }
          .font-warn {
            margin-top: .6rem;
            padding: .4rem .6rem;
            background: #fff3d6;
            border-left: 3px solid #c08a3e;
            font-size: .76rem;
          }
          @media (max-width: 1300px) {
            .facsimile-frame img, .page { height: 620px; }
          }
          @media (max-width: 1000px) {
            .compare { flex-direction: column; align-items: center; }
            .facsimile-frame img, .page { height: 560px; }
          }
        </style>
      </head>
      <body>
        <header class="bar">
          <span>清語老乞大 卷之一　縦書き表示の再現（影印画像・HTML 再現の並列）</span>
        </header>

        <div class="stage">
          <div class="compare">
            <!-- 影印画像 -->
            <div class="panel facsimile">
              <div class="panel-label">
                影印画像
                <small>朝鮮司譯院刊『清語老乞大』巻之一・第一葉表</small>
              </div>
              <div class="facsimile-frame">
                <img src="{//tei:graphic[1]/@url}" alt="清語老乞大 卷之一 第一葉表"/>
              </div>
            </div>

            <!-- HTML 再現 -->
            <div class="panel recon">
              <div class="panel-label">
                HTML 再現（XSLT 出力）
                <small>満州文字（CSS writing-mode 縦書き）＋ハングル音注＋諺解（割書）</small>
              </div>
              <div class="page">
                <!-- 題簽列：<head> 由来 -->
                <div class="col title-col">
                  <div class="title-cn">清語老乞大</div>
                  <div class="title-vol">卷之一</div>
                </div>
                <!-- 各 <cb/> に対して1列を生成 -->
                <xsl:apply-templates select="$all-cbs" mode="column"/>
              </div>
            </div>
          </div>
        </div>

        <aside class="legend">
          <h2>版面の読み方</h2>
          <dl>
            <dt>読む方向</dt><dd>題簽（左端）の右隣から始まり、左→右に列が進む。各列は上→下。</dd>
            <dt>太字の縦列</dt><dd>満州文字（Mongolian script 派生）。CSS の writing-mode で縦書き描画。</dd>
            <dt>満州文字右の小字</dt><dd>ハングルによる満州語の音注。<code>&lt;w&gt;</code>内の<code>&lt;note place="marginRight"&gt;</code>で符号化。</dd>
            <dt>本文下の2行小字</dt><dd>中世韓国語訳の割書。<code>&lt;note type="warigaki"&gt;</code>内の<code>&lt;lb/&gt;</code>で2行に分割。</dd>
            <dt>列の境界</dt><dd>影印の物理的な改列を <code>&lt;cb/&gt;</code> でマークアップ。文の途中で改列されることを構造的に表現。</dd>
            <dt>2列並列表示</dt><dd>左が影印画像、右が XSLT による HTML 再現。同じ版面を 2 形態で対比できます。</dd>
          </dl>
          <div class="font-warn">
            ※ 影印画像が原本そのものか写本・翻刻かは確認していません。本ページは TEI 符号化と XSLT による縦書きレイアウトの再現を目的とした学術用デモです。<br/>
            ※ 満州文字の表示には Manchu/Mongolian 対応フォント（Noto Sans Mongolian 等）を Google Fonts から自動読込し、CSS の <code>writing-mode: vertical-lr; text-orientation: mixed</code> で縦書きしています。ネットワーク非接続環境では字形が変わることがあります。iOS Safari は 17.4 以降で Mongolian の上下方向を正しく描画します。
          </div>
        </aside>
      </body>
    </html>
  </xsl:template>

  <!-- 各 <cb/> に対して1列を生成。
       this-cb と next-cb の間にある <w> と <note type='warigaki'> を文書順で出力する。 -->
  <xsl:template match="tei:cb" mode="column">
    <xsl:variable name="this-cb" select="."/>
    <xsl:variable name="cb-pos" select="count(preceding::tei:cb) + 1"/>
    <xsl:variable name="next-cb" select="$all-cbs[position() = $cb-pos + 1]"/>

    <div class="col manchu-col">
      <xsl:choose>
        <xsl:when test="$next-cb">
          <xsl:apply-templates
            select="following::tei:w[count(. | $next-cb/preceding::tei:w) = count($next-cb/preceding::tei:w)]
                  | following::tei:note[@type='warigaki'][count(. | $next-cb/preceding::tei:note) = count($next-cb/preceding::tei:note)]"
            mode="content"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- 最終列: 以降のすべて -->
          <xsl:apply-templates
            select="following::tei:w | following::tei:note[@type='warigaki']"
            mode="content"/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- <w>: 満州文字 (HTML/CSS writing-mode 縦書き) + 音注ハングル -->
  <xsl:template match="tei:w" mode="content">
    <xsl:variable name="m-text" select="normalize-space(text()[normalize-space()][1])"/>
    <xsl:variable name="phon" select="tei:note[@type='phon']"/>
    <span class="word">
      <span class="m-text" lang="mnc-Mong"><xsl:value-of select="$m-text"/></span>
      <span class="m-pron"><xsl:value-of select="normalize-space($phon)"/></span>
    </span>
  </xsl:template>

  <!-- <note type='warigaki'>: 2行の細い縦書き -->
  <xsl:template match="tei:note[@type='warigaki']" mode="content">
    <xsl:variable name="lines" select="text()[normalize-space()]"/>
    <span class="warigaki">
      <span class="wari-line"><xsl:value-of select="normalize-space($lines[1])"/></span>
      <span class="wari-line"><xsl:value-of select="normalize-space($lines[2])"/></span>
    </span>
  </xsl:template>

</xsl:stylesheet>
