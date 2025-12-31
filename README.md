# static-app

静的ファイル（HTML, JavaScript, CSS）のみで動作するWebアプリケーションのためのプロジェクトです。
Webブラウザ上で完結し、バックエンドサーバーを必要としないアプリケーションを開発・デプロイします。

## プロジェクト概要

このプロジェクトは、静的Webアプリケーションのソースコードと、AWS上にデプロイするためのインフラストラクチャ構成をモノレポとして管理しています。

## ディレクトリ構成

```
/
├── infrastructure/prod/     # 本番環境用 Terraformソース
├── infrastructure/stg/      # ステージング環境用 Terraformソース
├── frontend/                # フロントエンドアプリケーション
└── README.md
```

## 環境構成

本プロジェクトでは、以下の2つの環境を使用しています：

- **本番環境 (Production)**: 本番用AWSアカウントで管理され、`infrastructure/prod/`配下のTerraformソースで構成
- **ステージング環境 (Staging)**: 開発・検証用AWSアカウントで管理され、`infrastructure/stg/`配下のTerraformソースで構成

各環境は独立したAWSアカウントで運用され、Terraformによってインフラストラクチャがコード管理されています。

## 技術スタック

### フロントエンド
- HTML
- JavaScript
- CSS

### インフラストラクチャ
- AWS (S3, Route53など)
- Terraform

## セットアップ

### 前提条件
- Terraformがインストールされていること
- 各環境のAWSアカウントへのアクセス権限が設定されていること
- AWS CLIが設定されていること

### インフラストラクチャのデプロイ

#### ステージング環境
```bash
cd infrastructure/stg
terraform init
terraform plan
terraform apply
```

#### 本番環境
```bash
cd infrastructure/prod
terraform init
terraform plan
terraform apply
```

## 開発フロー

1. `frontend/`ディレクトリでアプリケーションを開発
2. ステージング環境でテスト・検証
3. 問題がなければ本番環境へデプロイ

## 注意事項

- 本番環境への変更は慎重に行ってください
- Terraformの実行前には必ず`plan`で変更内容を確認してください
- 機密情報（AWS認証情報など）はリポジトリにコミットしないでください
