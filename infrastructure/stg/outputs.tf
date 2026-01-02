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

output "apps_s3_bucket_id" {
  description = "The ID of the apps S3 bucket"
  value       = module.apps_s3_bucket.bucket_id
}

output "apps_cloudfront_distribution_id" {
  description = "The ID of the apps CloudFront distribution"
  value       = module.apps_cloudfront.distribution_id
}

output "apps_cloudfront_domain_name" {
  description = "The domain name of the apps CloudFront distribution"
  value       = module.apps_cloudfront.distribution_domain_name
}

output "apps_route53_record_fqdn" {
  description = "The FQDN of the apps Route53 record"
  value       = module.apps_route53_record.record_fqdn
}
