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
  description = "Map of A records (IPv4 addresses)"
  default     = {}
}

variable "records_aaaa" {
  type        = map(list(string))
  description = "Map of AAAA records (IPv6 addresses)"
  default     = {}
}

variable "records_caa" {
  type        = map(list(string))
  description = "Map of CAA records (Certificate Authority Authorization)"
  default     = {}
}

variable "records_cname" {
  type        = map(list(string))
  description = "Map of CNAME records (canonical name aliases)"
  default     = {}
}

variable "records_mx" {
  type        = map(list(string))
  description = "Map of MX records (mail exchange)"
  default     = {}
}

variable "records_txt" {
  type        = map(list(string))
  description = "Map of TXT records (text records)"
  default     = {}
}

variable "records_ns" {
  type        = map(list(string))
  description = "Map of NS records (name server delegation)"
  default     = {}
}

variable "records_wr" {
  type        = map(string)
  description = "Map of web redirect records (domain -> redirect URL)"
  default     = {}
}

variable "ttl" {
  description = "Default TTL for all DNS records (in seconds)"
  type        = number
  default     = 3600
}

variable "ttl_acm" {
  description = "TTL for ACM validation records (in seconds)"
  type        = number
  default     = 60
}

variable "ttl_ns" {
  description = "TTL for NS records (in seconds)"
  type        = number
  default     = 172800
}
