/* ======== i18n ======== */
const I18N = {
  ja: {
    dropMain:    '.docx ファイルをドラッグ&ドロップ',
    dropSub:     'またはクリックして選択',
    convert:     '変換する',
    sample:      'サンプル .docx で試す',
    sampleDl:    'サンプル .docx をダウンロード',
    clear:       'クリア',
    sending:     'TEI Garage に送信中…',
    resultTitle: '変換結果 (TEI/XML)',
    copy:        'XML をコピー',
    copied:      'コピー済み',
    download:    'ダウンロード',
    errDocx:     '.docx ファイルを選択してください。',
    errServer:   'サーバエラー',
    errConvert:  '変換に失敗しました。',
    errCopy:     'クリップボードへのコピーに失敗しました。',
    tabXml:      'XML',
    tabPreview:  'プレビュー',
    modeConvert: 'DOCX → TEI 変換',
    modeViewer:  'TEI/XML ビューワ',
    xmlDropMain: 'TEI/XML ファイルをドラッグ&ドロップ',
    xmlDropSub:  'またはクリックして選択',
    viewerTitle: 'TEI/XML ビューワ',
    landingSubtitle: '作成・編集・公開でたどる TEI/XML のワークフロー',
    convertDesc: '.docx ファイルを TEI Garage API で TEI/XML に変換します。',
    viewerDesc:  'TEI/XML ファイルをアップロードして構文ハイライトとプレビューで確認できます。',
    procCreate:     '作成する',
    procEdit:       '編集する',
    procPublish:    '公開する',
    modeEditor:  'TEI/IIIF エディタ',
    editorDesc:  'TEI/XML と IIIF 画像を並べて翻刻・タグ付けを行う外部エディタです。別タブで開きます。',
    toolsStepLabel: 'この工程で広く使われている定番ツール',
    toolScannerDesc:   '画像フォルダを Apple Vision で OCR し、facsimile zone 付きの TEI/XML を生成する macOS アプリ。',
    toolOxygenDesc:    'TEI 編集の事実上の標準とされる商用 XML エディタ。TEI 用フレームワークを内蔵。',
    toolSxmlDesc:      'VS Code で TEI/XML を編集するための拡張機能。RELAX NG による検証と入力補完。',
    toolLeafDesc:      'ブラウザ上で動作するオープンソースの TEI/XML エディタ。',
    toolTeipubDesc:    'TEI 文書をデジタル版として公開するためのプラットフォーム。',
    toolCeteiceanDesc: 'TEI/XML をブラウザでそのまま表示する JavaScript ライブラリ。本サイトのプレビューでも使用。',
    backToTop:   '← トップへ',
    viewerSubtitle: 'TEI/XML ファイルを可視化して確認',
    convertNote: 'このツールは、<a href="https://teigarage.tei-c.org/" target="_blank" rel="noopener">TEI Garage</a> API を利用して .docx ファイルを TEI/XML に変換するためのツールです。TEI/XML には膨大な数のタグがあり、プロジェクトごとに使用するタグやそのタグ付け方法を選択して利用します。そのため、変換結果をプロジェクトでそのまま利用するには、用途に応じたタグの変更や追加といった処理が別途必要になる場合があります。',
    viewerNote: 'このビューワは、<a href="https://teigarage.tei-c.org/" target="_blank" rel="noopener">TEI Garage</a> によって生成される TEI/XML を想定しています。TEI/XML のタグ体系はプロジェクトごとに異なるため、すべての TEI/XML ファイルの表示に対応しているわけではありません。',
    sampleXml: 'サンプル TEI/XML で試す',
    siteFooter: 'Copyright : Toyo Bunko 2025',
    modeExamples:    'XSL ギャラリー',
    examplesSubtitle:'プロジェクト別の TEI 変換サンプルと、再利用できる XSL スタイルシート集',
    examplesDesc:    'プロジェクト別の TEI 変換サンプルと、ダウンロードして使える XSL スタイルシート集。OCR 結果フォルダや公開済み XML も可視化できます。',
    examplesNote:    '各 XSL は XSLT 1.0 で書かれた単体で完結するスタイルシートです。「XSL をダウンロード」から取得して、ご自身のプロジェクトでそのまま利用できます。サンプルのほか、お手元の TEI/XML ファイル・OCR 結果フォルダ・公開済み XML（?url= パラメータ）も読み込めます。',
    exCatalog:       'XSL カタログ',
    exYourData:      '自分のデータで試す',
    exDropMain:      'TEI/XML ファイルまたはフォルダをドラッグ&ドロップ',
    exDropSub:       'またはクリックして TEI/XML ファイルを選択',
    exFolderBtn:     '📁 OCR フォルダを選択',
    exFolderHint:    'OCR 結果フォルダ（tei.xml と images/）を丸ごと読み込みます',
    exResultTitle:   '変換結果',
    exOpenTab:       '新しいタブで開く',
    exApplied:       '適用中:',
    exTrySample:     'サンプルで試す',
    exDownloadXsl:   'XSL をダウンロード',
    exInputFile:     '単一 XML',
    exInputFolder:   'フォルダ',
    errXmlParse:     'XML を解析できませんでした。整形式の XML か確認してください。',
    errXsl:          'XSLT 変換に失敗しました。XSLT 1.0 で記述された XSL か確認してください。',
    errSample:       'サンプルの読み込みに失敗しました。',
    errFolderNoXml:  'フォルダ内に XML ファイルが見つかりませんでした。',
    errFetchUrl:     '指定された URL を読み込めませんでした（CORS 制限の可能性があります）:',
    modePublisher:    'TEI ギャラリー',
    publisherSubtitle:'XML を選び、XSL を選んで、全画面表示で公開ビューを開く',
    publisherDesc:    'XML 文書と XSL スタイルシートを左右に並べ、組み合わせて全画面の公開ビューを開きます。',
    publisherNote:    '左で XML 文書を、右で XSL スタイルシートを選ぶと、その組み合わせを全画面表示（view.html）で開きます。XML 一覧には同梱サンプルと登録済みのオンライン XML が並び、URL やファイルで一時的に追加することもできます。',
    pubStep1:         'XML 文書を選ぶ',
    pubStep1Hint:     '表示したい資料を 1 つ選びます',
    pubStep2:         'XSL を選ぶ',
    pubStep2Hint:     '表示方式（レイアウト）を 1 つ選びます',
    pubStep3:         '全画面表示で開く',
    pubStep3Hint:     '選んだ XML と XSL を新しいタブで表示します',
    pubAddTitle:      '自分の XML を追加する',
    pubAddPlaceholder:'https://…/tei.xml',
    pubAdd:           'URL を追加',
    pubAddFile:       'ファイルを追加',
    pubScopeBundled:  '同梱',
    pubScopeRemote:   'オンライン',
    pubScopeAdded:    '追加分',
    pubOpen:          '全画面表示で開く',
    pubPickXmlFirst:  '左で XML 文書を選択してください。',
    pubSelXml:        'XML:',
    pubSelXsl:        'XSL:',
    pubNone:          '未選択',
    errXmlUrl:        'XML の URL を入力してください。',
    errCatalog:       'カタログ（catalog.json）の読み込みに失敗しました。',
    pubLicense:       '利用条件:',
    pubViewXml:       'XML を見る',
    pubViewXsl:       'XSL を見る',
    metaLinkFromPub:  'ⓘ 一覧に表示される情報の出典について',
    metaPageTitle:    'メタデータの出典',
    metaSubtitle:     'TEI ギャラリーの一覧に並ぶ情報が、ファイルのどこから来ているか',
    metaIntro:        'TEI ギャラリー（<a href="publisher.html">publisher.html</a>）に並ぶタイトル・概要・言語・カテゴリ・ライセンスは、手入力ではなく TEI/XML と XSL のファイル自身から自動抽出され、catalog.json に書き出されています。抽出は scripts/build-catalog.mjs が行います。',
    metaXmlHeading:   'XML 文書のメタデータ',
    metaXmlIntro:     '各 XML 文書の teiHeader から、次の要素を取り出します。名前空間プレフィックス（tei: など）は無視されます。',
    metaXslHeading:   'XSL スタイルシートのメタデータ',
    metaXslIntro:     '各 XSL ファイル先頭のコメント内にある、次の構造化行から取り出します。',
    metaColField:     '表示項目',
    metaColSource:    '取得元（TEI 要素）',
    metaColNote:      '補足',
    metaColComment:   'コメント行',
    metaFieldTitle:   'タイトル',
    metaFieldDesc:    '概要説明',
    metaFieldLang:    '言語',
    metaFieldCat:     'カテゴリ',
    metaFieldLicense: 'ライセンス',
    metaXmlTitleNote:   'type 属性付きの title（副題など）は読み飛ばし、最初の本タイトルを採用します。',
    metaXmlDescNote:    'abstract が無い場合は msDesc の summary を使います。',
    metaXmlLangNote:    'language が無い場合は textLang の mainLang 属性を使います。',
    metaXmlCatNote:     'textClass 内の最初の term を採用します。',
    metaXmlLicenseNote: 'licence が無い場合は availability 内の p、それも無ければ availability の status 属性を使います。',
    metaNotesHeading: 'その他の挙動',
    metaNoteRemote:   'オンライン文書は取得した teiHeader を優先し、欠けた項目は sources.json の fallback で補います。取得に失敗した場合は fallback のみを使います。',
    metaNoteScope:    '「同梱／オンライン／追加分」バッジは、sources.json の登録区分（ファイル同梱か、リモート URL か）と、画面上で一時的に追加したものかを表します。',
    metaNoteInput:    'XSL の「単一 XML／フォルダ」バッジは catalog.json ではなく、common.js の XSL_CATALOG の input 設定に基づきます。',
    metaNoteRebuild:  'catalog.json は生成物です。XML・XSL・sources.json を変更したら npm run catalog で再生成してください。',
    themeAuto:  '自動',
    themeLight: 'ライト',
    themeDark:  'ダーク',
  },
  en: {
    dropMain:    'Drag & drop a .docx file',
    dropSub:     'or click to select',
    convert:     'Convert',
    sample:      'Try with sample .docx',
    sampleDl:    'Download sample .docx',
    clear:       'Clear',
    sending:     'Sending to TEI Garage…',
    resultTitle: 'Result (TEI/XML)',
    copy:        'Copy XML',
    copied:      'Copied',
    download:    'Download',
    errDocx:     'Please select a .docx file.',
    errServer:   'Server error',
    errConvert:  'Conversion failed.',
    errCopy:     'Failed to copy to clipboard.',
    tabXml:      'XML',
    tabPreview:  'Preview',
    modeConvert: 'DOCX → TEI Convert',
    modeViewer:  'TEI/XML Viewer',
    xmlDropMain: 'Drag & drop a TEI/XML file',
    xmlDropSub:  'or click to select',
    viewerTitle: 'TEI/XML Viewer',
    landingSubtitle: 'A TEI/XML workflow: create, edit, publish',
    convertDesc: 'Convert .docx files to TEI/XML using the TEI Garage API.',
    viewerDesc:  'Upload TEI/XML files to view with syntax highlighting and preview.',
    procCreate:     'Create',
    procEdit:       'Edit',
    procPublish:    'Publish',
    modeEditor:  'TEI/IIIF Editor',
    editorDesc:  'An external editor for transcription and tagging with TEI/XML and IIIF images side by side. Opens in a new tab.',
    toolsStepLabel: 'Established tools widely used at this stage',
    toolScannerDesc:   'A macOS app that runs Apple Vision OCR over a folder of images to generate TEI/XML with facsimile zones.',
    toolOxygenDesc:    'The de facto standard commercial XML editor for TEI, with a built-in TEI framework.',
    toolSxmlDesc:      'A VS Code extension for editing TEI/XML, with RELAX NG validation and autocompletion.',
    toolLeafDesc:      'An open-source, browser-based editor for TEI/XML.',
    toolTeipubDesc:    'A platform for publishing TEI documents as digital editions.',
    toolCeteiceanDesc: 'A JavaScript library that renders TEI/XML directly in the browser; also used for previews on this site.',
    backToTop:   '← Back',
    viewerSubtitle: 'Visualize and verify TEI/XML files',
    convertNote: 'This tool converts .docx files to TEI/XML using the <a href="https://teigarage.tei-c.org/" target="_blank" rel="noopener">TEI Garage</a> API. Since TEI/XML has a vast number of tags and each project selects its own tagging scheme, additional processing — such as modifying or adding tags — may be required before using the output in your project.',
    viewerNote: 'This viewer is designed for TEI/XML generated by <a href="https://teigarage.tei-c.org/" target="_blank" rel="noopener">TEI Garage</a>. Because TEI/XML tagging schemes vary by project, not all TEI/XML files may display correctly.',
    sampleXml: 'Try with sample TEI/XML',
    siteFooter: 'Copyright : Toyo Bunko 2025',
    modeExamples:    'XSL Gallery',
    examplesSubtitle:'Project-specific TEI transformation samples and reusable XSL stylesheets',
    examplesDesc:    'A catalog of project-specific TEI transformation samples and downloadable XSL stylesheets. OCR result folders and published XML can be visualized too.',
    examplesNote:    'Each XSL is a self-contained XSLT 1.0 stylesheet. Use "Download XSL" to grab it and reuse it as-is in your own project. Besides the samples, you can load your own TEI/XML file, an OCR result folder, or a published XML via the ?url= parameter.',
    exCatalog:       'XSL Catalog',
    exYourData:      'Try your own data',
    exDropMain:      'Drag & drop a TEI/XML file or folder',
    exDropSub:       'or click to choose a TEI/XML file',
    exFolderBtn:     '📁 Choose an OCR folder',
    exFolderHint:    'Loads an entire OCR result folder (tei.xml and images/)',
    exResultTitle:   'Result',
    exOpenTab:       'Open in new tab',
    exApplied:       'Applied:',
    exTrySample:     'Try sample',
    exDownloadXsl:   'Download XSL',
    exInputFile:     'Single XML',
    exInputFolder:   'Folder',
    errXmlParse:     'Could not parse the XML. Make sure it is well-formed.',
    errXsl:          'XSLT transformation failed. Make sure the XSL is written in XSLT 1.0.',
    errSample:       'Failed to load the sample.',
    errFolderNoXml:  'No XML file was found in the folder.',
    errFetchUrl:     'Could not load the given URL (possibly a CORS restriction):',
    modePublisher:    'TEI Gallery',
    publisherSubtitle:'Pick an XML, pick an XSL, and open the published view full-screen',
    publisherDesc:    'Lists XML documents and XSL stylesheets side by side; combine them to open a full-screen published view.',
    publisherNote:    'Pick an XML document on the left and an XSL stylesheet on the right to open that combination full-screen (view.html). The XML list holds bundled samples and registered online XML; you can also add one temporarily by URL or file.',
    pubStep1:         'Choose an XML document',
    pubStep1Hint:     'pick one source document to display',
    pubStep2:         'Choose an XSL',
    pubStep2Hint:     'pick one display style (layout)',
    pubStep3:         'Open full-screen',
    pubStep3Hint:     'opens the chosen XML and XSL in a new tab',
    pubAddTitle:      'Add your own XML',
    pubAddPlaceholder:'https://…/tei.xml',
    pubAdd:           'Add URL',
    pubAddFile:       'Add a file',
    pubScopeBundled:  'Bundled',
    pubScopeRemote:   'Online',
    pubScopeAdded:    'Added',
    pubOpen:          'Open full-screen',
    pubPickXmlFirst:  'Select an XML document on the left first.',
    pubSelXml:        'XML:',
    pubSelXsl:        'XSL:',
    pubNone:          'none',
    errXmlUrl:        'Enter the URL of an XML file.',
    errCatalog:       'Failed to load the catalog (catalog.json).',
    pubLicense:       'License:',
    pubViewXml:       'View XML',
    pubViewXsl:       'View XSL',
    metaLinkFromPub:  'ⓘ Where the listed information comes from',
    metaPageTitle:    'Where the metadata comes from',
    metaSubtitle:     'Which part of each file the TEI Gallery listing draws from',
    metaIntro:        'The titles, descriptions, languages, categories and licenses listed in the TEI Gallery (<a href="publisher.html">publisher.html</a>) are not hand-typed: they are extracted automatically from the TEI/XML and XSL files themselves and written to catalog.json. The extraction is done by scripts/build-catalog.mjs.',
    metaXmlHeading:   'XML document metadata',
    metaXmlIntro:     'The following elements are taken from each XML document’s teiHeader. Namespace prefixes (tei: etc.) are ignored.',
    metaXslHeading:   'XSL stylesheet metadata',
    metaXslIntro:     'Taken from the following structured lines inside the leading comment at the top of each XSL file.',
    metaColField:     'Field',
    metaColSource:    'Source (TEI element)',
    metaColNote:      'Notes',
    metaColComment:   'Comment line',
    metaFieldTitle:   'Title',
    metaFieldDesc:    'Description',
    metaFieldLang:    'Languages',
    metaFieldCat:     'Category',
    metaFieldLicense: 'License',
    metaXmlTitleNote:   'A title with a type attribute (a subtitle, etc.) is skipped; the first main title is used.',
    metaXmlDescNote:    'If there is no abstract, the summary inside msDesc is used.',
    metaXmlLangNote:    'If there is no language element, the mainLang attribute of textLang is used.',
    metaXmlCatNote:     'The first term inside textClass is used.',
    metaXmlLicenseNote: 'If there is no licence, the p inside availability is used; failing that, the status attribute of availability.',
    metaNotesHeading: 'Other behavior',
    metaNoteRemote:   'For online documents the fetched teiHeader takes precedence, and any missing field is filled from the fallback in sources.json. If the fetch fails, only the fallback is used.',
    metaNoteScope:    'The Bundled / Online / Added badge reflects how the entry is registered in sources.json (a bundled file or a remote URL), or whether it was added on the page for the session.',
    metaNoteInput:    'The Single XML / Folder badge on XSL entries comes from the input setting of XSL_CATALOG in common.js, not from catalog.json.',
    metaNoteRebuild:  'catalog.json is a generated file. After changing any XML, XSL or sources.json, regenerate it with npm run catalog.',
    themeAuto:  'Auto',
    themeLight: 'Light',
    themeDark:  'Dark',
  }
};

/* ======== Shared XSL catalog ========
   Used by the XSL gallery (examples.js) and the TEI Publisher (publisher.js).
   Each entry is a standalone XSLT 1.0 stylesheet under xsl/. */
const XSL_CATALOG = [
  {
    id: 'reading',
    xsl: 'xsl/tei-reading.xsl',
    input: 'file',
    sample: { kind: 'file', path: 'xml/tei-guide/tei.xml' },
    title: { ja: '本文リーディングビュー', en: 'Reading view' },
    desc: {
      ja: 'TEI 本文を、見出し・段落・リスト・表・強調・注として読みやすい HTML に整形します。',
      en: 'Renders the TEI body as readable HTML with headings, paragraphs, lists, tables and notes.',
    },
  },
  {
    id: 'notes',
    xsl: 'xsl/tei-notes.xsl',
    input: 'file',
    sample: { kind: 'file', path: 'xml/tei-guide/tei.xml' },
    title: { ja: '注釈一覧', en: 'Notes list' },
    desc: {
      ja: '文書中の note 要素をすべて抽出し、種別・内容の一覧表にまとめます。',
      en: 'Extracts every note element into a single table of place and content.',
    },
  },
  {
    id: 'bibliography',
    xsl: 'xsl/tei-bibliography.xsl',
    input: 'file',
    sample: { kind: 'file', path: 'xml/tei-guide/tei.xml' },
    title: { ja: '書誌情報テーブル', en: 'Bibliography table' },
    desc: {
      ja: 'teiHeader からタイトル・著者・出版情報・改訂履歴などのメタデータを抽出し表示します。',
      en: 'Pulls title, author, publication details and revision history out of the teiHeader.',
    },
  },
  {
    id: 'ocr',
    xsl: 'xsl/tei-ocr-facsimile.xsl',
    input: 'folder',
    sample: { kind: 'folder', dir: 'xml/ocr-sample', xml: 'tei.xml' },
    title: { ja: 'OCR 翻刻ビュー', en: 'OCR transcription view' },
    desc: {
      ja: 'OCR 出力の TEI を、ページ画像と行ごとの翻刻テキストを左右に並べて表示する検証ビューです。TEIScanner が生成する検証ビューと同じスタイルシートです。',
      en: 'A verification view placing each page image beside its numbered OCR lines — the same stylesheet TEIScanner produces.',
    },
  },
  {
    id: 'vellum',
    xsl: 'xsl/tei-vellum.xsl',
    input: 'file',
    sample: { kind: 'file', path: 'xml/vellum/tei.xml' },
    title: { ja: 'Vellum 契約文書ビュー', en: 'Vellum contract document view' },
    desc: {
      ja: '東洋文庫「モロッコの羊皮紙契約文書」プロジェクト専用。写本記述・IIIF 画像・各証文（deed）のアラビア語翻刻（RTL）を表示します。',
      en: 'Dedicated to the Toyo Bunko "Vellum Contract Documents from Morocco" project: manuscript description, IIIF image, and the right-to-left Arabic transcription of each deed.',
    },
  },
  {
    id: 'urenja',
    xsl: 'xsl/tei-urenja.xsl',
    input: 'file',
    sample: { kind: 'file',
      path: 'https://u-renja.toyobunko-lab.jp/api/dts/document?resource=https://u-renja.toyobunko-lab.jp/api/iiif/2/001-01/manifest' },
    title: { ja: '酉蓮社 翻刻ビュー', en: 'Yūrensha transcription view' },
    desc: {
      ja: '酉蓮社プロジェクトのスタイルシート。NDL古典籍OCR で生成した TEI を、ページごとに本文翻刻と OpenSeadragon の画像（拡大縮小・行 zone）を並べ、ページャーで送って表示します。',
      en: 'The Yūrensha project stylesheet: a paged view of NDL classical-book OCR TEI, each page showing the transcription beside an OpenSeadragon image (zoom/pan, line zones).',
    },
  },
];

/* ======== Shared site chrome (header / footer) ========
   Injected on every page that loads common.js, so the header and footer
   live in exactly one place. The header carries only the site title and
   the theme / language / GitHub controls — page navigation is reached
   from the landing page, not a nav menu. */
function renderChrome() {
  const githubIcon =
    '<svg width="20" height="20" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">' +
    '<path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0016 8c0-4.42-3.58-8-8-8z"/>' +
    '</svg>';

  const header =
    '<header class="site-header">' +
      '<a href="index.html" class="site-title">TEI Tools</a>' +
      '<nav class="site-nav">' +
        '<button class="theme-btn" id="themeBtn">🌓 自動</button>' +
        '<button class="lang-btn" id="langBtn" title="Switch to English">EN</button>' +
        '<a href="https://github.com/toyo-bunko/tei-tools" target="_blank" rel="noopener" class="site-nav-github" aria-label="View on GitHub">' + githubIcon + '</a>' +
      '</nav>' +
    '</header>';

  document.body.insertAdjacentHTML('afterbegin', header);
  document.body.insertAdjacentHTML('beforeend',
    '<footer class="site-footer" data-i18n="siteFooter">Copyright : Toyo Bunko 2025</footer>');
}
renderChrome();

var lang = 'ja';

function t(key) { return I18N[lang][key] || key; }

function applyLang() {
  document.documentElement.lang = lang;
  const langBtn = document.getElementById('langBtn');
  langBtn.textContent = lang === 'ja' ? 'EN' : 'JA';
  langBtn.title = lang === 'ja' ? 'Switch to English' : '日本語に切り替え';
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    if (I18N[lang][key] != null) {
      if (el.querySelector('a') || I18N[lang][key].includes('<a ')) {
        el.innerHTML = I18N[lang][key];
      } else {
        el.textContent = I18N[lang][key];
      }
    }
  });
}

document.getElementById('langBtn').addEventListener('click', () => {
  lang = lang === 'ja' ? 'en' : 'ja';
  applyLang();
  updateThemeBtn(getThemeMode());
});

/* ======== XML pretty-print ======== */
function formatXml(xml) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(xml, 'application/xml');
  if (doc.querySelector('parsererror')) return xml;

  const indent = '  ';
  const lines = [];
  const declMatch = xml.match(/^(<\?xml[^?]*\?>)/);
  if (declMatch) lines.push(declMatch[1]);

  function serialize(node, level) {
    const pad = indent.repeat(level);

    if (node.nodeType === Node.TEXT_NODE) {
      if (node.textContent.trim()) lines.push(pad + node.textContent.trim());
      return;
    }
    if (node.nodeType === Node.COMMENT_NODE) {
      lines.push(pad + '<!--' + node.textContent + '-->');
      return;
    }
    if (node.nodeType === Node.PROCESSING_INSTRUCTION_NODE) {
      lines.push(pad + '<?' + node.target + ' ' + node.data + '?>');
      return;
    }
    if (node.nodeType !== Node.ELEMENT_NODE) return;

    let tag = '<' + node.tagName;
    for (const attr of node.attributes) {
      tag += ' ' + attr.name + '="' + attr.value.replace(/&/g,'&amp;').replace(/"/g,'&quot;') + '"';
    }

    const children = node.childNodes;
    if (children.length === 0) { lines.push(pad + tag + '/>'); return; }

    if (children.length === 1 && children[0].nodeType === Node.TEXT_NODE) {
      const text = children[0].textContent;
      lines.push(pad + tag + '>' + text.replace(/&/g,'&amp;').replace(/</g,'&lt;') + '</' + node.tagName + '>');
      return;
    }

    let hasElement = false, hasText = false;
    for (const c of children) {
      if (c.nodeType === Node.ELEMENT_NODE) hasElement = true;
      if (c.nodeType === Node.TEXT_NODE && c.textContent.trim()) hasText = true;
    }

    if (hasElement && hasText) {
      const ser = new XMLSerializer();
      let inner = '';
      for (const c of children) inner += ser.serializeToString(c);
      lines.push(pad + tag + '>' + inner + '</' + node.tagName + '>');
      return;
    }

    lines.push(pad + tag + '>');
    for (const child of children) serialize(child, level + 1);
    lines.push(pad + '</' + node.tagName + '>');
  }

  serialize(doc.documentElement, 0);
  return lines.join('\n');
}

/* ======== XML syntax highlight (single-pass tokenizer) ======== */
function highlightXml(xml) {
  const out = [];
  let i = 0;
  while (i < xml.length) {
    if (xml[i] === '<') {
      let end;
      if (xml.startsWith('<!--', i)) {
        end = xml.indexOf('-->', i); end = end === -1 ? xml.length : end + 3;
        out.push('<span class="comment">' + esc(xml.slice(i, end)) + '</span>');
      } else if (xml.startsWith('<?', i)) {
        end = xml.indexOf('?>', i); end = end === -1 ? xml.length : end + 2;
        out.push('<span class="decl">' + esc(xml.slice(i, end)) + '</span>');
      } else {
        end = xml.indexOf('>', i); end = end === -1 ? xml.length : end + 1;
        out.push(highlightElement(xml.slice(i, end)));
      }
      i = end;
    } else {
      let next = xml.indexOf('<', i);
      if (next === -1) next = xml.length;
      out.push(esc(xml.slice(i, next)));
      i = next;
    }
  }
  return out.join('');
}

function esc(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function highlightElement(tag) {
  const re = /^(<\/?)(\s*)([\w:\-]+)([\s\S]*?)(\/?>)$/;
  const m = tag.match(re);
  if (!m) return esc(tag);

  let r = esc(m[1]) + m[2] + '<span class="tag">' + esc(m[3]) + '</span>';
  if (m[4].trim()) {
    r += m[4].replace(/([\w:\-]+)\s*=\s*"([^"]*)"/g, (_, n, v) =>
      '<span class="attr-name">' + esc(n) + '</span>=<span class="attr-val">"' + esc(v) + '"</span>'
    );
  }
  return r + esc(m[5]);
}

/* ======== Error helpers ======== */
function showError(msg) {
  const errorDiv = document.getElementById('error');
  errorDiv.textContent = msg;
  errorDiv.classList.add('active');
}

function hideError() {
  const errorDiv = document.getElementById('error');
  errorDiv.classList.remove('active');
}

/* ======== Tab switching ======== */
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    document.getElementById(btn.dataset.tab).classList.add('active');
  });
});

/* ======== TEI Preview with CETEIcean ======== */
function renderTeiPreview(xmlString) {
  const teiPreview = document.getElementById('teiPreview');
  teiPreview.innerHTML = '';
  const ct = new CETEI();
  ct.makeHTML5(xmlString, function(data) {
    teiPreview.appendChild(data);
  });
}

/* ======== Theme switching ======== */
const THEME_MODES = ['auto', 'light', 'dark'];
const THEME_ICONS = { auto: '🌓', light: '☀️', dark: '🌙' };
const THEME_I18N  = { auto: 'themeAuto', light: 'themeLight', dark: 'themeDark' };

function getThemeMode() {
  return localStorage.getItem('theme') || 'auto';
}

function updateThemeBtn(mode) {
  const btn = document.getElementById('themeBtn');
  btn.textContent = THEME_ICONS[mode] + ' ' + t(THEME_I18N[mode]);
  btn.title = t(THEME_I18N[mode]);
}

function applyTheme(mode) {
  const isDark = mode === 'dark' ||
    (mode === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches);
  document.body.classList.toggle('dark', isDark);
  updateThemeBtn(mode);
}

(function initTheme() {
  const mode = getThemeMode();
  applyTheme(mode);
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    if (getThemeMode() === 'auto') applyTheme('auto');
  });
})();

document.getElementById('themeBtn').addEventListener('click', () => {
  const current = getThemeMode();
  const next = THEME_MODES[(THEME_MODES.indexOf(current) + 1) % THEME_MODES.length];
  localStorage.setItem('theme', next);
  applyTheme(next);
});

/* ======== Utility ======== */
function formatSize(bytes) {
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}
