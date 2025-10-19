variable "enabled" {
  description = "Whether to enable Route 53 resources"
  type        = bool
  default     = true
}

variable "primary_domain" {
  description = "The primary domain name to manage in Route 53"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]?\\.[a-z]{2,}$", var.primary_domain))
    error_message = "The primary_domain must be a valid domain name."
  }
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

  validation {
    condition     = var.ttl >= 60 && var.ttl <= 86400
    error_message = "TTL must be between 60 (1 minute) and 86400 (24 hours) seconds."
  }
}

variable "ttl_acm" {
  description = "TTL for ACM validation records (in seconds)"
  type        = number
  default     = 60

  validation {
    condition     = var.ttl_acm >= 60 && var.ttl_acm <= 3600
    error_message = "ACM validation TTL must be between 60 and 3600 seconds."
  }
}

variable "ttl_ns" {
  description = "TTL for NS records (in seconds)"
  type        = number
  default     = 172800

  validation {
    condition     = var.ttl_ns >= 60 && var.ttl_ns <= 172800
    error_message = "NS record TTL must be between 60 and 172800 (2 days) seconds."
  }
}
