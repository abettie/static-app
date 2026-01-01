output "hosted_zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = module.hosted_zone.zone_id
}

output "hosted_zone_name_servers" {
  description = "The name servers for the hosted zone"
  value       = module.hosted_zone.name_servers
}

output "hosted_zone_arn" {
  description = "The ARN of the hosted zone"
  value       = module.hosted_zone.zone_arn
}

output "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate"
  value       = module.ssl_certificate.certificate_arn
}

output "ssl_certificate_domain" {
  description = "The domain name of the SSL certificate"
  value       = module.ssl_certificate.certificate_domain_name
}

output "ssl_certificate_status" {
  description = "The status of the SSL certificate"
  value       = module.ssl_certificate.certificate_status
}
