# Plan: application/ を s3-files/apps/, s3-files/memo/ に分割

## Context

S3 sync 先が apps と memo の2バケットに分かれたことで、従来の単一 `application/` ディレクトリではどのファイルがどのバケット向けかが不明確になった。  
`s3-files/apps/` と `s3-files/memo/` に分割することで、バケットとディレクトリが1対1対応し、sync コマンドのパスが直感的になる。

## 変更内容

### 1. ファイル移動

| 移動元 | 移動先 |
|--------|--------|
| `application/index.html` | `s3-files/apps/index.html` |
| `application/kuku/` | `s3-files/apps/kuku/` |
| （新規作成） | `s3-files/memo/index.html`（ダミー） |

- `application/` ディレクトリは削除

### 2. README.md の更新

**対象ファイル:** `/workspace/README.md`

- **ディレクトリ構成セクション**: `application/` を `s3-files/apps/`, `s3-files/memo/` に差し替え
- **プログラムソースデプロイセクション**: sync コマンドを apps/memo × stg/prod の4パターンに拡充
- **開発フローセクション**: `application/` への言及を `s3-files/apps/`, `s3-files/memo/` に修正

```markdown
## プログラムソースデプロイ

### apps

#### ステージング環境
```bash
cd $(git rev-parse --show-toplevel) && export AWS_PROFILE=static-stg && aws s3 sync ./s3-files/apps/ s3://apps-stg-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066/
```

#### 本番環境
```bash
cd $(git rev-parse --show-toplevel) && export AWS_PROFILE=static-prod && aws s3 sync ./s3-files/apps/ s3://apps-prod-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066/
```

### memo

#### ステージング環境
```bash
cd $(git rev-parse --show-toplevel) && export AWS_PROFILE=static-stg && aws s3 sync ./s3-files/memo/ s3://memo-stg-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066/
```

#### 本番環境
```bash
cd $(git rev-parse --show-toplevel) && export AWS_PROFILE=static-prod && aws s3 sync ./s3-files/memo/ s3://memo-prod-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066/
```
```

### 3. CLAUDE.md の更新

**対象ファイル:** `/workspace/CLAUDE.md`

プロジェクト構成のディレクトリツリーを修正:
- `frontend/` → `s3-files/apps/`, `s3-files/memo/` に変更

## 最終ディレクトリ構成

```
/
├── infrastructure/
│   ├── modules/
│   ├── prod/
│   └── stg/
├── s3-files/
│   ├── apps/              # apps-{env}-{uuid} バケット向け
│   │   ├── index.html
│   │   └── kuku/
│   └── memo/              # memo-{env}-{uuid} バケット向け
│       └── index.html     # ダミー（将来のコンテンツに置き換え）
└── README.md
```

## 検証方法

1. `s3-files/apps/index.html` と `s3-files/apps/kuku/` が存在することを確認
2. `s3-files/memo/` が存在することを確認
3. `application/` ディレクトリが削除されていることを確認
4. README.md の sync コマンドのパスが `./s3-files/apps/`, `./s3-files/memo/` になっていることを確認
5. （任意）ステージング環境で実際に sync を実行し、S3 バケットにファイルが反映されることを確認
