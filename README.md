# TEI Tools

DOCX → TEI/XML 変換および TEI/XML ビューワを提供する、ビルド不要の静的 Web アプリケーションです。

A static web application for DOCX to TEI/XML conversion and TEI/XML viewing, with no build step required.

## Demo / デモ

**https://toyo-bunko.github.io/tei-tools/**

## Features / 機能

- **DOCX → TEI/XML 変換** / **DOCX → TEI/XML Conversion**
  - ドラッグ&ドロップまたはクリックで .docx ファイルをアップロード
  - [TEI Garage](https://teigarage.tei-c.org/) API による変換
  - サンプル .docx を内蔵
- **TEI/XML ビューワ** / **TEI/XML Viewer**
  - TEI/XML ファイルをアップロードして可視化
  - サンプル TEI/XML を内蔵
- **共通機能** / **Common**
  - XML 構文ハイライト表示
  - [CETEIcean](https://github.com/TEIC/CETEIcean) による TEI プレビュー（脚注ポップアップ対応）
  - クリップボードコピー・ダウンロード
  - 日本語 / 英語 UI 切替
  - ダークモード対応（ライト / ダーク / 自動）
  - レスポンシブデザイン

## File Structure / ファイル構成

```
docs/
├── index.html      # トップページ
├── convert.html    # DOCX → TEI/XML 変換ページ
├── viewer.html     # TEI/XML ビューワページ
├── common.js       # 共通ロジック（i18n, XML整形, テーマ切替等）
├── convert.js      # 変換ページ固有ロジック
├── viewer.js       # ビューワページ固有ロジック
├── style.css       # スタイル（ダークモード含む）
├── sample.docx     # サンプル DOCX ファイル
├── sample.xml      # サンプル TEI/XML ファイル
└── favicon.ico     # ファビコン
```

## Development / 開発

```bash
cd docs && python3 -m http.server 8000
```

## Deploy / デプロイ

```bash
cp .env.example .env
# .env を編集して接続情報を設定
./deploy.sh
```

## License / ライセンス

[MIT](LICENSE)

## Copyright

Copyright : Toyo Bunko 2025
