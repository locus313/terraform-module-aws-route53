output "zone_id" {
  description = "Zone ID of Route53 zone"
  value       = module.lo5t-dev.this_route53_zone_zone_id
}

output "name_servers" {
  description = "Name servers of Route53 zone"
  value       = module.lo5t-dev.this_route53_zone_name_servers
}
