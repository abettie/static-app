# プロジェクト概要

このプロジェクトは、AWSインフラ、フロントエンドを含むモノレポ構成です。

## プロジェクト構成

```
/
├── infrastructure/prod/     # Terraform本番用 (AWS)
├── infrastructure/stg/      # Terraform開発用 (AWS)
├── frontend/                # フロントエンドソース（HTML, JavaScriptなど）
```

## 技術スタック

- **インフラ**: Terraform (S3, Route53 etc.)
- **フロントエンド**: JavaScript, HTML, CSSなど

## 重要な開発ルール

### 確認が必要な操作

以下の操作を行う前には、必ずユーザーに確認を求めること:

- 既存ファイルの書き換え・変更
- ファイルの削除
- Terraformの`apply`や`destroy`コマンド実行
- `git push`などのリモートへの変更
- 本番環境に影響する可能性のある操作

### 確認不要な操作

以下の操作は確認なしで実行可能:

- 新規ファイルの作成
- ファイルの読み取り
- `terraform init`, `terraform plan`
- コードのフォーマット・リント

## よく使うコマンド

### Infrastructure (Terraform)

```bash
cd infrastructure
terraform init          # 初期化
terraform plan          # 実行計画の確認
terraform apply         # インフラの適用（要確認）
terraform destroy       # インフラの削除（要確認）
```

## 注意事項

- このプロジェクトでは、Claude Codeは必ず日本語で回答して下さい。技術用語は必要に応じて英語のまま使用可能です。
- `.env`ファイルや機密情報を含むファイルは変更しない
- `package-lock.json`や`yarn.lock`は直接編集しない
- 本番環境の設定ファイルには特に注意する
