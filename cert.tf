resource "aws_acm_certificate" "records_wr" {
  for_each = var.records_wr

  provider          = aws.acm
  domain_name       = each.key
  validation_method = "DNS"

  depends_on = [aws_route53_zone.this]
}

resource "aws_acm_certificate_validation" "records_wr" {
  for_each = var.records_wr

  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.records_wr[each.key].arn
  validation_record_fqdns = [for record in aws_route53_record.records_wr_validation : record.fqdn]

  depends_on = [aws_route53_zone.this]
}
