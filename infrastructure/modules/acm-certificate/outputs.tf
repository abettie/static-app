output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain_name" {
  description = "The domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_status" {
  description = "The status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "validation_record_fqdns" {
  description = "The FQDNs of the validation records"
  value       = [for record in aws_route53_record.cert_validation : record.fqdn]
}