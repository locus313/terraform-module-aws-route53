# Terraform AWS Route53 Module - AI Coding Agent Instructions

## Module Architecture

This is a reusable Terraform module that manages AWS Route53 hosted zones and DNS records with an advanced "web redirect" feature (`records_wr`). The redirect feature creates a complete infrastructure stack per domain: S3 bucket → CloudFront distribution → ACM certificate → Route53 A record to enable HTTPS redirects via CloudFront.

**Key architectural pattern**: All resources use `for_each` loops over input maps for dynamic resource creation. This module creates exactly ONE hosted zone per invocation (`var.primary_domain`) and multiple DNS records within it.

## Critical Multi-Provider Setup

**The module requires TWO AWS provider aliases**:
- Default provider (inherits from caller) - for Route53 and S3 resources
- `aws.acm` provider (must point to `us-east-1`) - for ACM certificates (CloudFront requirement)

See `versions.tf` for the `configuration_aliases` declaration. **Consumers MUST pass both providers** when calling the module:

```hcl
module "example" {
  source = "./terraform-module-aws-route53"
  providers = {
    aws.acm = aws.acm  # Must be us-east-1
  }
  # ...
}
```

## Records Web Redirect (records_wr) Flow

The `records_wr` variable creates a complete redirect infrastructure per domain in this order:

1. **S3 bucket** (`s3.tf`) - configured for website hosting with `redirect_all_requests_to`
2. **ACM certificate** (`cert.tf`) - created in us-east-1, DNS-validated automatically
3. **Route53 validation records** (`main.tf:records_wr_validation`) - uses complex for_each with flattened `domain_validation_options`
4. **CloudFront distribution** (`cloudfront.tf`) - uses `custom_origin_config` (not `s3_origin_config`) to support S3 website endpoints
5. **Route53 A record alias** (`main.tf:records_wr`) - points to CloudFront distribution

**Critical**: CloudFront must use `custom_origin_config` with `origin_protocol_policy = "http-only"` because S3 website endpoints don't support HTTPS origins. The User-Agent header (`base64sha512("REFER-SECRET-...")`) acts as authentication between CloudFront and S3 bucket policy.

## DNS Record Type Patterns

All standard DNS record types (`records_a`, `records_aaaa`, `records_cname`, `records_mx`, `records_txt`, `records_ns`, `records_caa`) follow the same pattern in `main.tf`:
- `for_each` over input variable map
- `zone_id = aws_route53_zone.this[0].zone_id` (note the `[0]` index - zone uses `count` not `for_each`)
- `depends_on = [aws_route53_zone.this]` explicit dependency
- Different TTL variables: `var.ttl` (default 3600), `var.ttl_acm` (60), `var.ttl_ns` (172800)

**Input format**: `map(list(string))` for most records (value is list), but `map(string)` for `records_wr` (single redirect URL).

## Validation Record Complexity (records_wr_validation)

The ACM certificate validation records use a complex nested loop pattern:

```hcl
for_each = {
  for dvo in flatten([
    for cert in aws_acm_certificate.records_wr : cert.domain_validation_options
  ]) : dvo.domain_name => { ... }
}
```

This flattens all `domain_validation_options` from all certificates and creates one Route53 record per domain that needs validation. The `aws_acm_certificate_validation.records_wr` resource then waits for all validation FQDNs.

## Testing Strategy

**Terratest** (`test/terraform_module_test.go`): 
- Uses `example/` directory as test fixture
- Pattern: `InitAndApply` → verify `zone_id` output → `Destroy`
- Requires AWS credentials with Route53/S3/CloudFront/ACM permissions
- Run: `cd test && go test -v -timeout 30m`

**Compliance testing** (`compliance/features/example.feature`):
- Gherkin-based BDD tests for policy compliance
- Checks TTL values on record types (e.g., A records must have TTL 3600)
- Run: `terraform-compliance -f compliance -p .`

**When adding features**: Update both test types and ensure `example/main.tf` demonstrates the new capability.

## Security & Compliance Annotations

Uses `tfsec` inline ignore comments for intentional security exceptions:
- `#tfsec:ignore:AWS002` (S3 bucket encryption) - redirect buckets don't store data
- `#tfsec:ignore:AWS020` (CloudFront viewer protocol) - allows HTTP for redirects
- `#tfsec:ignore:AWS045` (CloudFront logging) - not required for simple redirects
- `#tfsec:ignore:AWS071` (WAF) - not required for redirect distributions
- `#tfsec:ignore:AWS077` (S3 versioning) - no objects stored in redirect buckets

**Don't remove these without understanding the redirect use case** - these are empty S3 buckets that immediately redirect, not data storage.

## Development Workflows

```bash
# Initialize and validate module
terraform init
terraform validate

# Test with example configuration
cd example && terraform init && terraform plan

# Run Go integration tests (requires AWS credentials)
cd test && go test -v -timeout 30m

# Run compliance tests (requires terraform-compliance installed)
terraform-compliance -f compliance -p .

# Format code
terraform fmt -recursive
```

## Module Outputs

- `this_route53_zone_zone_id` - Zone ID for NS record delegation to child zones
- `this_route53_zone_name_servers` - NS servers to configure at domain registrar

## Common Gotchas

1. **Provider configuration**: Calling code must provide `providers = { aws.acm = aws.us-east-1 }` or ACM cert creation fails with region error
2. **Zone indexing**: Resources reference `aws_route53_zone.this[0]` not `aws_route53_zone.this` because zone uses `count = var.enabled ? 1 : 0`
3. **Validation record for_each**: The `records_wr_validation` uses a flattened nested loop - each certificate's `domain_validation_options` becomes a separate record
4. **CloudFront custom header**: The User-Agent header in `cloudfront.tf` acts as a shared secret for S3 bucket policy authentication (note: "not the best, but..." per inline comment)
5. **S3 website endpoint**: Must use `custom_origin_config` with `http-only` protocol because S3 website endpoints don't support HTTPS origins (this is an AWS limitation, not module choice)
