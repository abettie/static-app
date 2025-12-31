variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., staging, production)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}
