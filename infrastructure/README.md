# Infrastructure

このディレクトリには、AWS上にデプロイするためのTerraform構成が含まれています。

## ディレクトリ構成

```
infrastructure/
├── modules/
│   └── route53-hosted-zone/    # Route53ホストゾーンの共通モジュール
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── stg/                         # ステージング環境
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── prod/                        # 本番環境
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

## 環境

### ステージング環境 (stg)
- ドメイン: `stg-static.makedara.work`
- 用途: 開発・検証

### 本番環境 (prod)
- ドメイン: `static.makedara.work`
- 用途: 本番運用

## State管理

TerraformのstateファイルはS3バケットで管理されています。各環境で以下のリソースが使用されます:

### ステージング環境
- S3バケット: `terraform-state-stg-[uuid]`
- リージョン: `ap-northeast-1`

### 本番環境
- S3バケット: `terraform-state-prod-[uuid]`
- リージョン: `ap-northeast-1`

stateファイルは暗号化されて保存され、S3ネイティブのロック機構（`use_lockfile`）で同時実行を防止します。

> **Note**: Terraform 1.10以降では、S3ネイティブのステートロック機能を使用しており、DynamoDBテーブルは不要です。

### 初回セットアップ

初めてTerraformを使用する場合、S3バケットを事前に作成する必要があります:

```bash
# ステージング環境用
aws s3api create-bucket \
  --bucket terraform-state-stg-[uuid] \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-stg-[uuid] \
  --versioning-configuration Status=Enabled

# 本番環境用
aws s3api create-bucket \
  --bucket terraform-state-prod-[uuid] \
  --region ap-northeast-1 \
  --create-bucket-configuration LocationConstraint=ap-northeast-1

aws s3api put-bucket-versioning \
  --bucket terraform-state-prod-[uuid] \
  --versioning-configuration Status=Enabled
```

※ `[uuid]` 部分は実際のUUIDに置き換えてください。

## 使用方法

### 初期化

各環境ディレクトリで以下を実行します:

```bash
# ステージング環境
cd infrastructure/stg
terraform init

# 本番環境
cd infrastructure/prod
terraform init
```

### 実行計画の確認

```bash
terraform plan
```

### リソースの適用

```bash
terraform apply
```

実行後、ネームサーバー情報が出力されるので、ドメインレジストラ側でNSレコードを設定してください。

### リソースの削除

```bash
terraform destroy
```

## モジュール

### route53-hosted-zone

Route53のホストゾーンを作成する共通モジュールです。

#### 入力変数

- `domain_name` (required): ホストゾーンのドメイン名
- `environment` (required): 環境名 (staging, production など)
- `tags` (optional): 追加のタグ

#### 出力

- `zone_id`: ホストゾーンID
- `name_servers`: ネームサーバーのリスト
- `zone_arn`: ホストゾーンのARN

## 注意事項

- 各環境は独立したAWSアカウントで管理されることを想定しています
- Terraform実行前には必ず適切なAWS認証情報が設定されていることを確認してください
- 本番環境への変更は特に慎重に行ってください
