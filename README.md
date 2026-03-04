# DOCX → TEI/XML Converter

A simple, browser-based tool to convert Microsoft Word (.docx) files into TEI/XML format.

DOCX から TEI/XML への変換を行う、シンプルなブラウザベースのツールです。

## Demo / デモ

**https://tei-converter.pages.dev/**

## Features / 機能

- Drag & drop or click to upload .docx files / ドラッグ&ドロップまたはクリックで .docx ファイルをアップロード
- Instant conversion to TEI/XML via [TEI Garage](https://teigarage.tei-c.org/) API / TEI Garage API による即時変換
- Syntax-highlighted XML preview / シンタックスハイライト付きXMLプレビュー
- **TEI preview powered by [CETEIcean](https://github.com/TEIC/CETEIcean)** / **CETEIcean による TEI プレビュー表示**
- XML / Preview tab switching / XML・プレビュー タブ切り替え
- Note popup on hover / 注釈のホバーポップアップ表示
- Pretty-printed (indented) output / 整形済み（インデント付き）出力
- Copy to clipboard or download as .xml / クリップボードへコピーまたは .xml としてダウンロード
- Built-in sample .docx for quick testing / テスト用サンプル .docx を内蔵
- Japanese / English UI switch / 日本語・英語 UI切替
- No build step required / ビルド不要

## Usage / 使い方

1. Open the [demo site](https://tei-converter.pages.dev/) or serve the `docs/` directory locally.
2. Drop a `.docx` file onto the page (or click to select).
3. Click **Convert** / **変換する**.
4. Switch between **XML** and **Preview** tabs to view the result.
5. Copy to clipboard or download as `.xml`.

[デモサイト](https://tei-converter.pages.dev/)にアクセスするか、`docs/` ディレクトリをローカルで配信し、`.docx` ファイルをドロップして「変換する」をクリックしてください。**XML** タブと**プレビュー**タブを切り替えて結果を確認できます。

## How It Works / 仕組み

The conversion is performed server-side by the [TEI Garage](https://teigarage.tei-c.org/) REST API (maintained by the [TEI Consortium](https://tei-c.org/)). This tool provides a modern, minimal UI that sends the file to the API and displays the result.

変換処理は [TEI Consortium](https://tei-c.org/) が運営する [TEI Garage](https://teigarage.tei-c.org/) の REST API がサーバ側で行います。本ツールは、ファイルを API に送信して結果を表示するモダンで軽量な UI を提供します。

## File Structure / ファイル構成

```
docs/
├── index.html    # HTML structure / HTML構造
├── style.css     # Styles (UI + TEI preview) / スタイル
├── app.js        # JavaScript (conversion, preview, UI) / JavaScript
└── sample.docx   # Sample file / サンプルファイル
```

## Self-Hosting / セルフホスティング

Serve the `docs/` directory with any HTTP server:

`docs/` ディレクトリを任意の HTTP サーバで配信してください。

```bash
# Serve with any HTTP server
cd docs && python3 -m http.server 8000
```

## License / ライセンス

[MIT](LICENSE)
