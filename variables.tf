variable "enabled" {
  description = "Whether to enable Route 53 resources"
  type        = bool
  default     = true
}

variable "primary_domain" {
  description = "The domain name to manage"
  type        = string
}

variable "records_a" {
  type        = map(list(string))
  description = "Map of A records separate by comma (,)"
  default     = {}
}

variable "records_aaaa" {
  type        = map(list(string))
  description = "Map of AAAA records separate by comma (,)"
  default     = {}
}

variable "records_caa" {
  type        = map(list(string))
  description = "Map of CAA records separate by comma (,)"
  default     = {}
}

variable "records_cname" {
  type        = map(list(string))
  description = "Map of CNAME records separate by comma (,)"
  default     = {}
}

variable "records_mx" {
  type        = map(list(string))
  description = "Map of MX records separate by comma (,)"
  default     = {}
}

variable "records_txt" {
  type        = map(list(string))
  description = "Map of TXT records separate by comma (,)"
  default     = {}
}

variable "records_ns" {
  type        = map(list(string))
  description = "Map of NS records separate by comma (,)"
  default     = {}
}

variable "records_wr" {
  type        = map(string)
  description = "Map of redirect records"
  default     = {}
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
