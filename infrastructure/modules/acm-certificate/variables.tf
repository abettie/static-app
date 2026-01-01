variable "domain_name" {
  description = "The domain name for the certificate"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route53 hosted zone ID for DNS validation"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., staging, production)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the certificate"
  type        = map(string)
  default     = {}
}