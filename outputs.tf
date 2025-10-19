output "this_route53_zone_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = var.enabled ? aws_route53_zone.this[0].zone_id : null
}

output "this_route53_zone_name_servers" {
  description = "Name servers of Route53 zone"
  value       = var.enabled ? aws_route53_zone.this[0].name_servers : []
}
