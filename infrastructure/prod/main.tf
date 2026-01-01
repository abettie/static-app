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
