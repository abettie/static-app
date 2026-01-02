terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-prod-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066"
    key          = "terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
      Project     = "static-app"
    }
  }
}

# CloudFront requires ACM certificates in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "Terraform"
      Project     = "static-app"
    }
  }
}

module "hosted_zone" {
  source = "../modules/route53-hosted-zone"

  domain_name = var.domain_name
  environment = "production"

  tags = {
    Project = "static-app"
  }
}

module "ssl_certificate" {
  source = "../modules/acm-certificate"

  providers = {
    aws = aws.us_east_1
  }

  domain_name      = var.ssl_domain_name
  route53_zone_id  = module.hosted_zone.zone_id
  environment      = "production"

  tags = {
    Project = "static-app"
    Purpose = "CloudFront"
  }
}

module "apps_s3_bucket" {
  source = "../modules/s3-static-website"

  bucket_name = "apps-prod-675f09ae-9bb8-4d10-b5f2-77c2f1bb1066"
  environment = "production"

  tags = {
    Project = "static-app"
    Purpose = "Apps hosting"
  }
}

module "apps_cloudfront" {
  source = "../modules/cloudfront-s3"

  domain_name                    = var.ssl_domain_name
  s3_bucket_id                   = module.apps_s3_bucket.bucket_id
  s3_bucket_regional_domain_name = module.apps_s3_bucket.bucket_regional_domain_name
  certificate_arn                = module.ssl_certificate.certificate_arn
  environment                    = "production"

  tags = {
    Project = "static-app"
    Purpose = "Apps distribution"
  }
}

module "apps_route53_record" {
  source = "../modules/route53-cloudfront-record"

  zone_id                    = module.hosted_zone.zone_id
  domain_name                = var.ssl_domain_name
  cloudfront_domain_name     = module.apps_cloudfront.distribution_domain_name
  cloudfront_hosted_zone_id  = module.apps_cloudfront.distribution_hosted_zone_id

  tags = {
    Project = "static-app"
  }
}
