locals {
  # Empty out every record map when disabled, so all record resources (which key
  # off these locals) naturally create zero instances instead of erroring on the
  # zone's count-gated aws_route53_zone.this[0] reference.
  records_a     = var.enabled ? var.records_a : {}
  records_aaaa  = var.enabled ? var.records_aaaa : {}
  records_caa   = var.enabled ? var.records_caa : {}
  records_cname = var.enabled ? var.records_cname : {}
  records_mx    = var.enabled ? var.records_mx : {}
  records_txt   = var.enabled ? var.records_txt : {}
  records_ns    = var.enabled ? var.records_ns : {}
  records_wr    = var.enabled ? var.records_wr : {}
}
