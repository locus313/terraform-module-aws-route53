variable "primary_domain" {
  description = "Route53 Primary domain"
  type        = any
}

variable "ttl" {
  description = "Default TTL for All records"
  type        = number
  default     = "3600"
}

variable "ttl_acm" {
  description = "Default TTL for acm records"
  type        = number
  default     = "60"
}

variable "ttl_ns" {
  description = "Default TTL for ns records"
  type        = number
  default     = "172800"
}

variable "records_a" {
  type        = map
  description = "Map of A records separate by comma (,)"
  default     = {}
}

variable "records_caa" {
  type        = map
  description = "Map of CAA records separate by comma (,)"
  default     = {}
}

variable "records_cname" {
  type        = map
  description = "Map of CNAME records separate by comma (,)"
  default     = {}
}

variable "records_mx" {
  type        = map
  description = "Map of MX records separate by comma (,)"
  default     = {}
}

variable "records_txt" {
  type        = map
  description = "Map of TXT records separate by comma (,)"
  default     = {}
}

variable "records_ns" {
  type        = map
  description = "Map of NS records separate by comma (,)"
  default     = {}
}

variable "records_wr" {
  type        = map
  description = "Map of redirect records"
  default     = {}
}
