# ACM Certificate for web redirect domains
# These certificates are created in us-east-1 (via aws.acm provider) as required by CloudFront
resource "aws_acm_certificate" "records_wr" {
  for_each = local.records_wr

  provider          = aws.acm
  domain_name       = each.key
  validation_method = "DNS"
  tags              = var.tags

  depends_on = [aws_route53_zone.this]
}

# ACM Certificate Validation
# Waits for this certificate's own DNS validation record to resolve
resource "aws_acm_certificate_validation" "records_wr" {
  for_each = local.records_wr

  provider        = aws.acm
  certificate_arn = aws_acm_certificate.records_wr[each.key].arn

  # Scoped to this certificate's own validation record only, so one domain's
  # validation issue can't block or delay unrelated records_wr certificates.
  validation_record_fqdns = [aws_route53_record.records_wr_validation[each.key].fqdn]

  depends_on = [
    aws_route53_zone.this,
    aws_route53_record.records_wr_validation
  ]
}
