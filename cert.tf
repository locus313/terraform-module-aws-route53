resource "aws_acm_certificate" "records_wr" {
  provider = aws.acm
  for_each   = toset(var.records_wr)
  domain_name       = each.key
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "records_wr" {
  provider = aws.acm
  for_each   = toset(var.records_wr)
  certificate_arn         = aws_acm_certificate.records_wr[each.key].arn
  validation_record_fqdns = [for record in aws_route53_record.records_wr_validation: record.fqdn]
}
