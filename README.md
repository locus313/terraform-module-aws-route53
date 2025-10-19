# AWS Route53 Terraform Module

[![Terraform](https://img.shields.io/badge/Terraform->=1.0-623CE4?style=flat-square&logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider->=4.0-FF9900?style=flat-square&logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

⭐ If you find this module useful, star it on GitHub — it helps a lot!

[Overview](#overview) • [Features](#features) • [Usage](#usage) • [Examples](#examples) • [API Reference](#api-reference)

---

A comprehensive Terraform module for managing AWS Route53 hosted zones and DNS records with an advanced **HTTPS web redirect** feature. This module simplifies DNS management while providing powerful capabilities like automatic SSL certificate provisioning and CloudFront-based redirects.

## Overview

This module creates and manages AWS Route53 resources with a focus on flexibility and ease of use. It supports all common DNS record types and includes a unique `records_wr` (web redirect) feature that automatically provisions the complete infrastructure needed for HTTPS redirects:

- 🔐 **Automatic SSL certificates** via AWS Certificate Manager
- 🌐 **CloudFront distribution** for global edge delivery
- 📦 **S3 bucket** configured for website redirection
- ✅ **DNS validation** handled automatically

## Features

- **Comprehensive DNS Record Support** - A, AAAA, CNAME, MX, TXT, NS, and CAA records
- **HTTPS Web Redirects** - Complete redirect infrastructure with a single configuration
- **Automatic SSL Certificates** - ACM certificates provisioned and validated automatically
- **CloudFront Integration** - Global edge delivery for web redirects
- **Flexible TTL Configuration** - Customize TTL values per record type
- **Multi-Provider Architecture** - Proper handling of us-east-1 requirements for CloudFront certificates

## Usage

### Basic Setup

First, you need to configure two AWS providers - one for your primary region and one for `us-east-1` (required for CloudFront ACM certificates):

```hcl
provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}
```

Then use the module:

```hcl
module "example_com" {
  source = "locus313/route53/aws"
  
  # Pass both providers
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  records_a = {
    "example.com" = ["12.23.45.56"]
  }
  
  records_cname = {
    "www.example.com" = ["example.com"]
  }
}
```

> [!IMPORTANT]
> The `aws.acm` provider **must** point to `us-east-1` for CloudFront certificate provisioning. This is an AWS requirement, not a module limitation.

## Examples

### Simple DNS Records

Create a basic hosted zone with A and CNAME records:

```hcl
module "simple_dns" {
  source = "locus313/route53/aws"
  
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  records_a = {
    "example.com"     = ["203.0.113.10"]
    "api.example.com" = ["203.0.113.20"]
  }
  
  records_cname = {
    "www.example.com"  = ["example.com"]
    "blog.example.com" = ["example.com"]
  }
}
```

### Email Configuration

Set up MX, SPF, and DKIM records for email:

```hcl
module "email_dns" {
  source = "locus313/route53/aws"
  
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  records_mx = {
    "example.com" = [
      "10 aspmx.l.google.com",
      "20 alt1.aspmx.l.google.com",
      "30 alt2.aspmx.l.google.com"
    ]
  }
  
  records_txt = {
    "example.com" = ["v=spf1 include:_spf.google.com ~all"]
    "google._domainkey.example.com" = [
      "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQ..."
    ]
  }
  
  records_caa = {
    "example.com" = ["0 issue \"letsencrypt.org\""]
  }
}
```

### HTTPS Web Redirects

Create HTTPS redirects with automatic SSL certificates:

```hcl
module "redirects" {
  source = "locus313/route53/aws"
  
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  # Automatically creates:
  # - S3 bucket with redirect configuration
  # - CloudFront distribution
  # - ACM certificate (validated via DNS)
  # - Route53 A record (CloudFront alias)
  records_wr = {
    "support.example.com" = "https://example.atlassian.net/servicedesk"
    "docs.example.com"    = "https://documentation.example.com"
    "status.example.com"  = "https://status.example.com/incidents"
  }
}
```

### Subdomain Delegation

Delegate subdomains to other AWS accounts or hosted zones:

```hcl
module "parent_zone" {
  source = "locus313/route53/aws"
  
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  records_ns = {
    "dev.example.com" = [
      "ns-1234.awsdns-12.org",
      "ns-5678.awsdns-34.com",
      "ns-9012.awsdns-56.net",
      "ns-3456.awsdns-78.co.uk"
    ]
    "staging.example.com" = [
      "ns-4321.awsdns-21.org",
      "ns-8765.awsdns-43.com"
    ]
  }
  
  # Custom TTL for NS records (default is 172800)
  ttl_ns = 86400
}
```

### IPv6 Support

Configure both IPv4 and IPv6 addresses:

```hcl
module "dual_stack" {
  source = "locus313/route53/aws"
  
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  records_a = {
    "example.com" = ["203.0.113.10"]
  }
  
  records_aaaa = {
    "example.com" = ["2001:0db8:85a3:0000:0000:8a2e:0370:7334"]
  }
}
```

### Complete Configuration

A comprehensive example with multiple record types:

```hcl
module "complete_example" {
  source = "locus313/route53/aws"
  
  providers = {
    aws.acm = aws.acm
  }
  
  primary_domain = "example.com"
  
  # Web redirects with HTTPS
  records_wr = {
    "support.example.com" = "https://example.atlassian.net/servicedesk"
  }
  
  # IPv4 addresses
  records_a = {
    "example.com"     = ["203.0.113.10"]
    "api.example.com" = ["203.0.113.20"]
  }
  
  # IPv6 addresses
  records_aaaa = {
    "example.com" = ["2001:0db8:85a3::8a2e:0370:7334"]
  }
  
  # Certificate Authority Authorization
  records_caa = {
    "example.com" = ["0 issue \"letsencrypt.org\""]
  }
  
  # Canonical names
  records_cname = {
    "www.example.com"      = ["example.com"]
    "calendar.example.com" = ["ghs.googlehosted.com"]
    "mail.example.com"     = ["ghs.googlehosted.com"]
  }
  
  # Mail exchange
  records_mx = {
    "example.com" = [
      "10 aspmx.l.google.com",
      "20 alt1.aspmx.l.google.com",
      "30 alt2.aspmx.l.google.com"
    ]
  }
  
  # Text records (SPF, DKIM, etc.)
  records_txt = {
    "example.com" = ["v=spf1 include:_spf.google.com ~all"]
    "google._domainkey.example.com" = [
      "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A..."
    ]
  }
  
  # Subdomain delegation
  records_ns = {
    "dev.example.com" = [
      "ns-1234.awsdns-12.org",
      "ns-5678.awsdns-34.com"
    ]
  }
  
  # Custom TTL values
  ttl     = 3600   # Default records (1 hour)
  ttl_acm = 60     # ACM validation records (1 minute)
  ttl_ns  = 172800 # NS records (48 hours)
}
```

## API Reference

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

### Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |
| aws.acm | >= 4.0 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `primary_domain` | The domain name to manage | `string` | n/a | yes |
| `enabled` | Whether to enable Route 53 resources | `bool` | `true` | no |
| `records_a` | Map of A records (IPv4 addresses) | `map(list(string))` | `{}` | no |
| `records_aaaa` | Map of AAAA records (IPv6 addresses) | `map(list(string))` | `{}` | no |
| `records_caa` | Map of CAA records (Certificate Authority Authorization) | `map(list(string))` | `{}` | no |
| `records_cname` | Map of CNAME records (canonical name aliases) | `map(list(string))` | `{}` | no |
| `records_mx` | Map of MX records (mail exchange) | `map(list(string))` | `{}` | no |
| `records_ns` | Map of NS records (name server delegation) | `map(list(string))` | `{}` | no |
| `records_txt` | Map of TXT records (text records) | `map(list(string))` | `{}` | no |
| `records_wr` | Map of web redirect records (domain → redirect URL) | `map(string)` | `{}` | no |
| `ttl` | Default TTL for all DNS records (in seconds) | `number` | `3600` | no |
| `ttl_acm` | TTL for ACM validation records (in seconds) | `number` | `60` | no |
| `ttl_ns` | TTL for NS records (in seconds) | `number` | `172800` | no |

### Outputs

| Name | Description |
|------|-------------|
| `this_route53_zone_zone_id` | Zone ID of Route53 zone |
| `this_route53_zone_name_servers` | Name servers of Route53 zone |
<!-- END_TF_DOCS -->

## Supported Record Types

| Record Type | Supported | Description |
|-------------|-----------|-------------|
| A | ✅ | IPv4 addresses |
| AAAA | ✅ | IPv6 addresses |
| CAA | ✅ | Certificate Authority Authorization |
| CNAME | ✅ | Canonical name aliases |
| MX | ✅ | Mail exchange |
| NS | ✅ | Name server delegation |
| TXT | ✅ | Text records |
| LOC | ❌ | Location information |
| PTR | ❌ | Reverse DNS lookups |
| SOA | ❌ | Start of authority (managed by AWS) |
| SRV | ❌ | Service locator |
| SPF | ❌ | Use TXT records instead |

## Resources Created

### For Standard DNS Records
- `aws_route53_zone` - Hosted zone for the domain
- `aws_route53_record` - DNS records of various types

### For Web Redirects (`records_wr`)
- `aws_s3_bucket` - Bucket configured for website redirect
- `aws_s3_bucket_policy` - Bucket policy to allow CloudFront access
- `aws_s3_bucket_website_configuration` - Redirect configuration
- `aws_acm_certificate` - SSL certificate (in us-east-1)
- `aws_acm_certificate_validation` - DNS validation
- `aws_cloudfront_distribution` - CDN for HTTPS redirect
- `aws_route53_record` - DNS records for domain and validation

## Development

### Running Tests

This module includes both Go-based Terratest and compliance tests:

```bash
# Run Terratest integration tests
cd test
go test -v -timeout 30m

# Run compliance tests
terraform-compliance -f compliance -p .
```

### Local Development

```bash
# Initialize and validate
terraform init
terraform validate

# Test with the example configuration
cd example
terraform init
terraform plan
```

## Important Notes

> [!NOTE]
> This module creates exactly **one hosted zone** per invocation. All DNS records are created within that zone.

> [!WARNING]
> The `records_wr` feature creates multiple AWS resources (S3, CloudFront, ACM, Route53) which may incur costs. CloudFront distributions can take 15-20 minutes to deploy.

> [!TIP]
> After creating a hosted zone, update your domain registrar's name servers to the values in `this_route53_zone_name_servers` output.

## Author

Module created and maintained by [Patrick Lewis](https://github.com/locus313).
