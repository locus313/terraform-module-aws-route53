# Terraform AWS Route53 Module - AI Coding Agent Instructions

## Module Architecture

This is a reusable Terraform module that manages AWS Route53 hosted zones and DNS records with an advanced "web redirect" feature (`records_wr`). The redirect feature creates a full stack: S3 bucket → CloudFront distribution → ACM certificate → Route53 A record to enable HTTPS redirects via CloudFront.

**Key architectural pattern**: All resources use `for_each` loops over input maps for dynamic resource creation. This module creates exactly ONE hosted zone per invocation (`var.primary_domain`) and multiple DNS records within it.

## Critical Multi-Provider Setup

**The module requires TWO AWS provider aliases**:
- Default provider (inherits from caller) - for Route53 and S3 resources
- `aws.acm` provider (must point to `us-east-1`) - for ACM certificates (CloudFront requirement)

See `versions.tf` for the configuration_aliases declaration. Consumers must pass both providers when calling the module using the `providers` block.

## Records Web Redirect (records_wr) Flow

The `records_wr` variable creates a complete redirect infrastructure per domain:

1. **S3 bucket** (`s3.tf`) - configured for website hosting with redirect-all-requests
2. **ACM certificate** (`cert.tf`) - created in us-east-1, DNS-validated automatically
3. **Route53 validation records** (`main.tf:records_wr_validation`) - uses complex for_each with flattened domain_validation_options
4. **CloudFront distribution** (`cloudfront.tf`) - uses custom_origin_config (not s3_origin_config) to support S3 website endpoints with custom User-Agent header authentication
5. **Route53 A record alias** (`main.tf:records_wr`) - points to CloudFront

**Critical**: CloudFront must use `custom_origin_config` with `origin_protocol_policy = "http-only"` because S3 website endpoints don't support HTTPS origins.

## DNS Record Type Patterns

All standard DNS record types (`records_a`, `records_aaaa`, `records_cname`, `records_mx`, `records_txt`, `records_ns`, `records_caa`) follow the same pattern in `main.tf`:
- `for_each` over input variable map
- `zone_id = aws_route53_zone.this[0].zone_id` (note the `[0]` index due to count)
- `depends_on = [aws_route53_zone.this]` explicit dependency
- Different TTL variables: `var.ttl` (default 3600), `var.ttl_acm` (60), `var.ttl_ns` (172800)

Input format: `map(list(string))` for most records (value is list), but `map(string)` for `records_wr` (single redirect URL).

## Testing Strategy

**Terratest** (`test/terraform_module_test.go`): Uses the `example/` directory as test fixture. Pattern: InitAndApply → verify output → Destroy.

**Compliance testing** (`compliance/features/example.feature`): Gherkin-based BDD tests for policy compliance, checking TTL values on record types.

When adding features, update both test types and ensure `example/main.tf` demonstrates the new capability.

## Security & Compliance Annotations

Uses `tfsec` inline ignore comments for intentional security exceptions:
- `#tfsec:ignore:AWS002` (S3 bucket encryption) - redirect buckets don't store data
- `#tfsec:ignore:AWS020` (CloudFront viewer protocol) - allows HTTP for redirects
- `#tfsec:ignore:AWS045` (CloudFront logging) - not required for simple redirects

**Don't remove these without understanding the redirect use case** - these are empty S3 buckets that immediately redirect, not data storage.

## Development Commands

```bash
# Initialize and validate
terraform init
terraform validate

# Test with example
cd example && terraform init && terraform plan

# Run Go tests (requires AWS credentials)
cd test && go test -v -timeout 30m

# Run compliance tests (requires terraform-compliance)
terraform-compliance -f compliance -p .
```

## Module Output Usage

- `this_route53_zone_zone_id` - Zone ID for NS record delegation
- `this_route53_zone_name_servers` - NS servers to configure at domain registrar

## Common Gotchas

1. **Provider configuration**: Ensure calling code provides `providers = { aws.acm = aws.us-east-1 }` or ACM cert creation fails
2. **Zone creation**: Resources use `aws_route53_zone.this[0]` not `aws_route53_zone.this` because zone uses `count` not `for_each`
3. **Validation record complexity**: The `records_wr_validation` for_each uses a flattened nested loop to create one record per domain_validation_option
4. **CloudFront custom header**: The User-Agent header in `cloudfront.tf` acts as a secret for S3 bucket policy authentication (commented as "not the best, but...")
