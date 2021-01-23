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

variable "records_a" {
  type        = any
  description = "Map of A records separate by comma and space (, )"
  default     = []
}

variable "records_cname" {
  type        = any
  description = "Map of CNAME records separate by comma and space (, )"
  default     = []
}

variable "records_mx" {
  type        = any
  description = "Map of MX records separate by comma and space (, )"
  default     = []
}

variable "records_txt" {
  type        = any
  description = "Map of TXT records separate by comma and space (, )"
  default     = []
}

variable "records_ns" {
  type        = any
  description = "Map of NS records separate by comma and space (, )"
  default     = []
}
