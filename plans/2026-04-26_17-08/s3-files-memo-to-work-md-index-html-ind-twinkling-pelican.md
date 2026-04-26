# ドキュポータル作成計画

## Context

`s3-files/memo/index.html` が現在「準備中」のみのプレースホルダーになっている。  
`to-work.md`（業務ノウハウ共有用ドキュメント）を追加したのをきっかけに、  
memoバケットをS3上のドキュメントへのポータルサイト「ドキュポータル」として整備する。

## 変更対象ファイル

- `/workspace/s3-files/memo/index.html` — 全体を書き換え（現在は12行のプレースホルダーのみ）
- `/workspace/s3-files/memo/to-work.md` → `dev-notes.md` にリネーム

## 実装方針

### デザインコンセプト

- アプリポータル（apps/index.html）は紫グラデーション → メモポータルは**緑〜ティール系**で差別化
- 目に優しいパステル系グリーン（`#43e97b` → `#38f9d7`）のグラデーション
- カード型UIは apps と同じ構造を踏襲（ホバー時のリフト効果、白カード）
- タイトルに書類系の絵文字（📚）を添える
- タグで「ノウハウ」「設定」などカテゴリを視覚的に示す

### カードの内容

| カード | リンク先 | アイコン | タイトル | 説明 |
|---|---|---|---|---|
| dev-notes.md | `dev-notes.md` | 🛠️ | 業務ノウハウ集 | alias, Claude Code設定, Vim設定など共有用メモ |

### HTML構造

```
body（グリーン〜ティール グラデーション背景）
└── .container
    ├── h1（📚 ドキュポータル）
    ├── p.subtitle（S3共有ドキュメント集）
    ├── .doc-grid（auto-fit, minmax 280px）
    │   └── a.doc-card[href="to-work.md"]
    │       ├── .doc-icon（🛠️）
    │       ├── .doc-title（業務ノウハウ集）
    │       ├── .doc-tags（<span>.tag × 3: alias / Claude Code / Vim）
    │       └── p.doc-description
    └── footer（© 2025 Document Portal）
```

### スタイルのポイント

- `background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)`
- カードの `.doc-title` カラー：`#2a9d6e`（アプリポータルの `#667eea` に相当）
- タグ（`.tag`）：パステル系の丸バッジ（緑・青・黄のバリエーション）
- hover時 `translateY(-8px)` — apps と同じ挙動
- レスポンシブ対応：apps と同じブレークポイント（768px, 480px）
- 将来ドキュメント追加用コメントアウトプレースホルダーを残す

## 実装手順

1. `to-work.md` を `dev-notes.md` にリネーム（`git mv`）
2. `s3-files/memo/index.html` をドキュポータルのHTMLに書き換え（リンク先は `dev-notes.md`）
3. GitHub Issue を立てる
4. feature ブランチを切る（`feature/issue-[N]-docuportal-memo-index`）
5. commit（`feat: memoのindex.htmlをドキュポータルに刷新、to-work.mdをdev-notes.mdにリネーム`）
6. PR作成（masterへ）

## 検証方法

- ブラウザで `index.html` をローカルで開き、カードが正しく表示されるか確認
- `dev-notes.md` へのリンクが正しく機能するか確認（相対パス `dev-notes.md`）
- スマホ幅（480px以下）でレイアウトが崩れないかDevToolsで確認
