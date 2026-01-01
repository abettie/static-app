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

実行後、ネームサーバー情報が出力されます。

### ドメインのNSレコード設定

**重要**: Route53でホストゾーンを作成した後、ドメインレジストラ（お名前.comなど）側でNSレコードを設定する必要があります。

#### 手順

1. **ホストゾーンの作成**
   - 上記の `terraform apply` を実行し、Route53にホストゾーンを作成します
   - 実行後、ネームサーバー情報が出力されます（4つのNSレコード）

2. **ネームサーバー情報の確認**
   ```bash
   # Terraformの出力から確認
   terraform output hosted_zone_name_servers

   # または、AWS CLIで確認
   aws route53 get-hosted-zone --id <HOSTED_ZONE_ID>
   ```

3. **ドメインレジストラでのNSレコード設定**
   - ドメインレジストラ（お名前.com、ムームードメインなど）の管理画面にログイン
   - 対象ドメインのネームサーバー設定画面を開く
   - Route53から出力された4つのネームサーバーを設定

   例（お名前.comの場合）:
   - ネームサーバー1: `ns-1234.awsdns-12.org`
   - ネームサーバー2: `ns-5678.awsdns-34.co.uk`
   - ネームサーバー3: `ns-901.awsdns-56.com`
   - ネームサーバー4: `ns-2345.awsdns-78.net`

4. **DNS伝播の待機**
   - NSレコードの変更がインターネット全体に伝播するまで、最大48時間かかる場合があります（通常は数時間以内）
   - 以下のコマンドで確認できます:
   ```bash
   dig NS <ドメイン名>
   # または
   nslookup -type=NS <ドメイン名>
   ```

> **Note**: ホストゾーンは作成した時点でAWSの課金が開始されます。NSレコードの設定を忘れると、ドメインが正しく機能しないため注意してください。

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
