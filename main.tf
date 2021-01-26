resource "aws_route53_zone" "this" {
  name       = var.primary_domain
}

resource "aws_route53_zone" "subthis" {
  count      = length(keys(var.sub_domain))
  name       = element(values(var.sub_domain), count.index )
}

resource "aws_route53_record" "records_a" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_a))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_a), count.index )
  type       = "A"
  ttl        = var.ttl
  records    = element(values(var.records_a), count.index)

}

resource "aws_route53_record" "records_wr" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_wr))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_wr), count.index )
  type       = "A"

  alias {
    name                   = aws_cloudfront_distribution.records_wr[count.index].domain_name
    zone_id                = aws_cloudfront_distribution.records_wr[count.index].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "records_wr_validation" {
  depends_on = [aws_route53_zone.this]
  for_each = {
    for dvo in flatten([
      for cert in aws_acm_certificate.records_wr: cert.domain_validation_options
    ]): dvo.domain_name => {
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
}

resource "aws_route53_record" "records_cname" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_cname))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_cname), count.index )
  type       = "CNAME"
  ttl        = var.ttl
  records    = element(values(var.records_cname), count.index)
}

resource "aws_route53_record" "records_mx" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_mx))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_mx), count.index )
  type       = "MX"
  ttl        = var.ttl
  records    = element(values(var.records_mx), count.index)
}

resource "aws_route53_record" "records_txt" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_txt))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_txt), count.index )
  type       = "TXT"
  ttl        = var.ttl
  records    = element(values(var.records_txt), count.index)
}

resource "aws_route53_record" "records_ns" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_ns))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_ns), count.index )
  type       = "NS"
  ttl        = var.ttl
  records    = element(values(var.records_ns), count.index)
}
