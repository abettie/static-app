variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
  default     = "stg-static.makedara.work"
}

variable "ssl_domain_name" {
  description = "Domain name for the SSL certificate"
  type        = string
  default     = "apps.stg-static.makedara.work"
}
