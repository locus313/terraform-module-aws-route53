output "this_route53_zone_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = var.enabled ? aws_route53_zone.this[0].zone_id : null
}

output "this_route53_zone_name_servers" {
  description = "Name servers of Route53 zone"
  value       = var.enabled ? aws_route53_zone.this[0].name_servers : []
}

output "records_wr_cloudfront_distribution_ids" {
  description = "Map of records_wr domain to CloudFront distribution ID"
  value       = { for domain, dist in aws_cloudfront_distribution.records_wr : domain => dist.id }
}

output "records_wr_cloudfront_distribution_domain_names" {
  description = "Map of records_wr domain to CloudFront distribution domain name"
  value       = { for domain, dist in aws_cloudfront_distribution.records_wr : domain => dist.domain_name }
}

output "records_wr_certificate_arns" {
  description = "Map of records_wr domain to validated ACM certificate ARN"
  value       = { for domain, cert in aws_acm_certificate_validation.records_wr : domain => cert.certificate_arn }
}

output "records_wr_s3_bucket_names" {
  description = "Map of records_wr domain to S3 origin bucket name"
  value       = { for domain, bucket in aws_s3_bucket.records_wr : domain => bucket.id }
}
