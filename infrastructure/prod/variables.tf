variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
  default     = "static.makedara.work"
}

variable "uuid" {
  description = "Unique identifier for resource names"
  type        = string
  default     = "675f09ae-9bb8-4d10-b5f2-77c2f1bb1066"
}
