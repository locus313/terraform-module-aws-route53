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
  records    = [ "split(", ", element(values(var.records_a), count.index))" ]

}

resource "aws_route53_record" "records_cname" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_cname))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_cname), count.index )
  type       = "CNAME"
  ttl        = var.ttl
  records    = [ "split(", ", element(values(var.records_cname), count.index))" ]
}

resource "aws_route53_record" "records_mx" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_mx))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_mx), count.index )
  type       = "MX"
  ttl        = var.ttl
  records    = [ "split(", ", element(values(var.records_mx), count.index))" ]
}

resource "aws_route53_record" "records_txt" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_txt))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_txt), count.index )
  type       = "TXT"
  ttl        = var.ttl
  records    = [ "split(", ", element(values(var.records_txt), count.index))" ]
}

resource "aws_route53_record" "records_ns" {
  depends_on = [aws_route53_zone.this]
  count      = length(keys(var.records_ns))
  zone_id    = aws_route53_zone.this.zone_id
  name       = element(keys(var.records_ns), count.index )
  type       = "NS"
  ttl        = var.ttl
  records    = [ "split(", ", element(values(var.records_ns), count.index))" ]
}
