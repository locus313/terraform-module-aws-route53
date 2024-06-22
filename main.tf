resource "aws_route53_zone" "this" {
  name  = var.primary_domain
  count = var.enabled ? 1 : 0
}

resource "aws_route53_record" "records_a" {
  for_each   = var.records_a

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "A"
  ttl        = var.ttl
  records    = each.value

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_aaaa" {
  for_each   = var.records_aaaa

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "AAAA"
  ttl        = var.ttl
  records    = each.value

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_caa" {
  for_each   = var.records_caa

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "CAA"
  ttl        = var.ttl
  records    = each.value

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_wr" {
  for_each   = var.records_wr

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "A"

  alias {
    name                   = aws_cloudfront_distribution.records_wr[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.records_wr[each.key].hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_wr_validation" {
  for_each = {
    for dvo in flatten([
      for cert in aws_acm_certificate.records_wr : cert.domain_validation_options
      ]) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.ttl_acm
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_cname" {
  for_each   = var.records_cname

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "CNAME"
  ttl        = var.ttl
  records    = each.value

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_mx" {
  for_each   = var.records_mx

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "MX"
  ttl        = var.ttl
  records    = each.value

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_txt" {
  for_each   = var.records_txt

  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "TXT"
  ttl        = var.ttl
  records    = each.value

  depends_on = [aws_route53_zone.this]
}

resource "aws_route53_record" "records_ns" {
  for_each   = var.records_ns
  
  zone_id    = aws_route53_zone.this.zone_id
  name       = each.key
  type       = "NS"
  ttl        = var.ttl_ns
  records    = each.value

  depends_on = [aws_route53_zone.this]
}
