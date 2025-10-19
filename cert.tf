# ACM Certificate for web redirect domains
# These certificates are created in us-east-1 (via aws.acm provider) as required by CloudFront
resource "aws_acm_certificate" "records_wr" {
  for_each = var.records_wr

  provider          = aws.acm
  domain_name       = each.key
  validation_method = "DNS"

  depends_on = [aws_route53_zone.this]
}

# ACM Certificate Validation
# Waits for DNS validation to complete by checking all validation FQDNs
resource "aws_acm_certificate_validation" "records_wr" {
  for_each = var.records_wr

  provider        = aws.acm
  certificate_arn = aws_acm_certificate.records_wr[each.key].arn

  # Collect all validation record FQDNs to ensure validation completes
  # Note: This includes FQDNs from all certificates, but AWS will only validate
  # the records matching this specific certificate's domain
  validation_record_fqdns = [for record in aws_route53_record.records_wr_validation : record.fqdn]

  depends_on = [
    aws_route53_zone.this,
    aws_route53_record.records_wr_validation
  ]
}
