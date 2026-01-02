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

#### 初回デプロイ時の注意事項

SSL証明書の発行にはDNS検証が必要なため、以下の手順でデプロイを行ってください：

1. **ホストゾーンの先行作成**

   まず、Route53のホストゾーンのみを作成します：
   ```bash
   cd infrastructure/[環境]  # prod または stg
   aws sso login --profile [プロファイル名]
   export AWS_PROFILE=[プロファイル名] && terraform init
   export AWS_PROFILE=[プロファイル名] && terraform plan -target=module.hosted_zone
   export AWS_PROFILE=[プロファイル名] && terraform apply -target=module.hosted_zone
   ```

2. **ドメインレジストラでNSレコードの設定**

   上記コマンド実行後に出力されるネームサーバー情報を、ドメインレジストラ側で設定してください。
   DNSの伝播には数分から48時間程度かかる場合があります。

3. **残りのリソースのデプロイ**

   NSレコードの設定が完了し、DNSの伝播を確認したら、残りのリソースをデプロイします：
   ```bash
   export AWS_PROFILE=[プロファイル名] && terraform plan
   export AWS_PROFILE=[プロファイル名] && terraform apply
   ```

#### ステージング環境
(例)
```bash
cd infrastructure/stg
aws sso login --profile static-stg
export AWS_PROFILE=static-stg && terraform init
export AWS_PROFILE=static-stg && terraform plan
export AWS_PROFILE=static-stg && terraform apply
```

#### 本番環境
(例)
```bash
cd infrastructure/prod
aws sso login --profile static-prod
export AWS_PROFILE=static-prod && terraform init
export AWS_PROFILE=static-prod && terraform plan
export AWS_PROFILE=static-prod && terraform apply
```

## 開発フロー

1. `frontend/`ディレクトリでアプリケーションを開発
2. ステージング環境でテスト・検証
3. 問題がなければ本番環境へデプロイ

## 注意事項

- 本番環境への変更は慎重に行ってください
- Terraformの実行前には必ず`plan`で変更内容を確認してください
- 機密情報（AWS認証情報など）はリポジトリにコミットしないでください
