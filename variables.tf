variable "primary_domain" {
  description = "Map of Route53 Primary domain parameters"
  type        = any
}

variable "sub_domain" {
  description = "Map of Route53 Primary domain parameters"
  type        = any
  default     = null
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

variable "records_a" {
  type        = map
  description = "Map of A records separate by comma and space (,)"
}

variable "records_cname" {
  type        = map
  description = "Map of CNAME records separate by comma and space (,)"
}

variable "records_mx" {
  type        = map
  description = "Map of MX records separate by comma and space (,)"
}

variable "records_txt" {
  type        = map
  description = "Map of TXT records separate by comma and space (,)"
}

variable "records_ns" {
  type        = map
  description = "Map of NS records separate by comma and space (,)"
}

variable "records_wr" {
  type        = map
  description = "Map of 301 http redirect records separate by comma and space (,)"
}
