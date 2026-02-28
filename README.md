# DOCX → TEI/XML Converter

A simple, browser-based tool to convert Microsoft Word (.docx) files into TEI/XML format.

DOCX から TEI/XML への変換を行う、シンプルなブラウザベースのツールです。

## Demo / デモ

**https://nakamura196.github.io/tei-converter/**

## Features / 機能

- Drag & drop or click to upload .docx files / ドラッグ&ドロップまたはクリックで .docx ファイルをアップロード
- Instant conversion to TEI/XML via [TEI Garage](https://teigarage.tei-c.org/) API / TEI Garage API による即時変換
- Syntax-highlighted XML preview / シンタックスハイライト付きXMLプレビュー
- Pretty-printed (indented) output / 整形済み（インデント付き）出力
- Copy to clipboard or download as .xml / クリップボードへコピーまたは .xml としてダウンロード
- Built-in sample .docx for quick testing / テスト用サンプル .docx を内蔵
- Japanese / English UI switch / 日本語・英語 UI切替
- Single HTML file, no build step, no dependencies / 単一HTMLファイル、ビルド不要、依存なし

## Usage / 使い方

1. Open `index.html` in a browser, or visit the [demo site](https://nakamura196.github.io/tei-converter/).
2. Drop a `.docx` file onto the page (or click to select).
3. Click **Convert** / **変換する**.
4. View, copy, or download the resulting TEI/XML.

ブラウザで `index.html` を開くか、[デモサイト](https://nakamura196.github.io/tei-converter/)にアクセスし、`.docx` ファイルをドロップして「変換する」をクリックしてください。

## How It Works / 仕組み

The conversion is performed server-side by the [TEI Garage](https://teigarage.tei-c.org/) REST API (maintained by the [TEI Consortium](https://tei-c.org/)). This tool provides a modern, minimal UI that sends the file to the API and displays the result.

変換処理は [TEI Consortium](https://tei-c.org/) が運営する [TEI Garage](https://teigarage.tei-c.org/) の REST API がサーバ側で行います。本ツールは、ファイルを API に送信して結果を表示するモダンで軽量な UI を提供します。

## Self-Hosting / セルフホスティング

Since this is a single HTML file with no dependencies, you can host it anywhere:

単一 HTML ファイルで依存関係がないため、どこでもホスティングできます。

```bash
# Local
open index.html

# Or serve with any HTTP server
python3 -m http.server 8000
```

## License / ライセンス

[MIT](LICENSE)
