# Plan: memo.static.makedara.work の CloudFront 接続追加

## Context

`apps.static.makedara.work` と同じアーキテクチャで、新しいサブドメイン `memo.static.makedara.work`（stg: `memo.static-stg.makedara.work`）を S3 バケット `memo-[prod/stg]-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066` に CloudFront 経由で接続する。

## 変更対象ファイル

- `infrastructure/prod/main.tf`
- `infrastructure/stg/main.tf`

## 追加する Terraform モジュール

既存の `apps_*` モジュール群と同じパターンで、`memo_*` モジュール群を各 `main.tf` に追加する。

### prod/main.tf に追加するブロック

```hcl
module "memo_ssl_certificate" {
  source = "../modules/acm-certificate"

  providers = {
    aws = aws.us_east_1
  }

  domain_name     = "memo.static.makedara.work"
  route53_zone_id = module.hosted_zone.zone_id
  environment     = "production"

  tags = {
    Project = "static-app"
    Purpose = "CloudFront"
  }
}

module "memo_s3_bucket" {
  source = "../modules/s3-static-website"

  bucket_name = "memo-prod-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066"
  environment = "production"

  tags = {
    Project = "static-app"
    Purpose = "Memo hosting"
  }
}

module "memo_cloudfront" {
  source = "../modules/cloudfront-s3"

  domain_name                    = "memo.static.makedara.work"
  s3_bucket_id                   = module.memo_s3_bucket.bucket_id
  s3_bucket_regional_domain_name = module.memo_s3_bucket.bucket_regional_domain_name
  certificate_arn                = module.memo_ssl_certificate.certificate_arn
  environment                    = "production"
  cache_ttl                      = 60

  tags = {
    Project = "static-app"
    Purpose = "Memo distribution"
  }
}

module "memo_route53_record" {
  source = "../modules/route53-cloudfront-record"

  zone_id                   = module.hosted_zone.zone_id
  domain_name               = "memo.static.makedara.work"
  cloudfront_domain_name    = module.memo_cloudfront.distribution_domain_name
  cloudfront_hosted_zone_id = module.memo_cloudfront.distribution_hosted_zone_id

  tags = {
    Project = "static-app"
  }
}
```

### stg/main.tf に追加するブロック

同様のブロックを stg 用の値で追加（`domain_name = "memo.static-stg.makedara.work"`、`bucket_name = "memo-stg-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066"`、`environment = "staging"`、`cache_ttl = 2`）。

## 再利用するモジュール

| モジュール | パス |
|---|---|
| ACM証明書 | `infrastructure/modules/acm-certificate/` |
| S3バケット | `infrastructure/modules/s3-static-website/` |
| CloudFront | `infrastructure/modules/cloudfront-s3/` |
| Route53レコード | `infrastructure/modules/route53-cloudfront-record/` |

## 注意事項

- `ssl_certificate` モジュール（apps用）と `hosted_zone` モジュールは既存のものをそのまま流用
- ACM 証明書は us-east-1 で作成（CloudFront の要件）
- Route53 Hosted Zone (`static.makedara.work` / `static-stg.makedara.work`) は既存のものを参照
- `variables.tf` の変更は不要（ドメイン名はモジュール呼び出し内に直書き）

## 検証手順

1. `cd infrastructure/prod && AWS_PROFILE=static-prod terraform init && AWS_PROFILE=static-prod terraform plan` でエラーがないか確認
2. `cd infrastructure/stg && AWS_PROFILE=static-stg terraform init && AWS_PROFILE=static-stg terraform plan` でエラーがないか確認
3. `terraform apply` はユーザーが手動で実行する（Claude Codeでは実行しない）
