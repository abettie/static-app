# Plan: ssl_domain_name変数廃止・UUID変数化

## Context

現在 `variables.tf` で管理されている `ssl_domain_name` 変数（`apps.static.makedara.work`）は、実質的に `"apps." + domain_name` で導出可能な値。変数として持つ必要がないため `main.tf` 内で直接 `"apps.${var.domain_name}"` として指定する形にリファクタリングする。また、S3バケット名に使われているUUID `675f09ae-9bb8-4d10-b5f2-77c2f1bb1066` を変数化して管理しやすくする。`terraform plan` の差分はゼロ（インフラ構成・設定値変更なし）。

---

## 変更対象ファイル

| ファイル | 変更内容 |
|---------|---------|
| `infrastructure/prod/variables.tf` | `ssl_domain_name` 削除、`uuid` 変数追加 |
| `infrastructure/prod/main.tf` | `var.ssl_domain_name` → `"apps.${var.domain_name}"`、ハードコードドメイン → `var.domain_name` 使用、UUID → `var.uuid` |
| `infrastructure/stg/variables.tf` | `ssl_domain_name` 削除、`uuid` 変数追加 |
| `infrastructure/stg/main.tf` | 同上（stg環境） |

---

## 詳細変更内容

### prod/variables.tf（stg/variables.tf も同様）

```hcl
# 削除
variable "ssl_domain_name" { ... }

# 追加
variable "uuid" {
  description = "Unique identifier for resource names"
  type        = string
  default     = "675f09ae-9bb8-4d10-b5f2-77c2f1bb1066"
}
```

---

### prod/main.tf の変更箇所

| 行 | 変更前 | 変更後 |
|----|--------|--------|
| 64 | `domain_name = var.ssl_domain_name` | `domain_name = "apps.${var.domain_name}"` |
| 77 | `bucket_name = "apps-prod-675f09ae-..."` | `bucket_name = "apps-prod-${var.uuid}"` |
| 89 | `domain_name = var.ssl_domain_name` | `domain_name = "apps.${var.domain_name}"` |
| 106 | `domain_name = var.ssl_domain_name` | `domain_name = "apps.${var.domain_name}"` |
| 122 | `domain_name = "memo.static.makedara.work"` | `domain_name = "memo.${var.domain_name}"` |
| 135 | `bucket_name = "memo-prod-675f09ae-..."` | `bucket_name = "memo-prod-${var.uuid}"` |
| 147 | `domain_name = "memo.static.makedara.work"` | `domain_name = "memo.${var.domain_name}"` |
| 164 | `domain_name = "memo.static.makedara.work"` | `domain_name = "memo.${var.domain_name}"` |

stg/main.tf も同様（`"memo.static-stg.makedara.work"` → `"memo.${var.domain_name}"`、`"apps-stg-UUID"` → `"apps-stg-${var.uuid}"`）

---

## 注意事項：backend ブロック

`backend "s3"` ブロック（main.tf 行12）は **Terraform の仕様上、変数補間不可**。
`terraform-state-prod-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066` はハードコードのまま維持する。

---

## 検証方法

```bash
cd infrastructure/prod
terraform init
terraform plan   # No changes. expected

cd ../stg
terraform init
terraform plan   # No changes. expected
```
