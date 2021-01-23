variable "primary_domain" {
  description = "Map of Route53 Primary domain parameters"
  type        = string
}

variable "sub_domain" {
  description = "Map of Route53 Primary domain parameters"
  type        = map
}

variable "ttl" {
  description = "Default TTL for All records"
  type        = number
  default     = "3600"
}

variable "records_a" {
  type        = map
  description = "Map of A records separate by comma and space (, )"
}

variable "records_cname" {
  type        = map
  description = "Map of CNAME records separate by comma and space (, )"
}

variable "records_mx" {
  type        = map
  description = "Map of MX records separate by comma and space (, )"
}

variable "records_txt" {
  type        = map
  description = "Map of TXT records separate by comma and space (, )"
}

variable "records_ns" {
  type        = map
  description = "Map of NS records separate by comma and space (, )"
}
