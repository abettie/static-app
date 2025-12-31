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
