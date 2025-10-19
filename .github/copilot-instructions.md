# Terraform AWS Route53 Module - AI Agent Instructions

## Architecture Overview

Reusable Terraform module for Route53 hosted zones and DNS records with an HTTPS web redirect feature (`records_wr`). Creates ONE hosted zone per invocation and manages multiple DNS records via `for_each` loops.

**Web redirect infrastructure** (`records_wr`): Single input creates S3 bucket → ACM certificate → CloudFront → Route53 A record alias for HTTPS redirects.

## Critical Multi-Provider Setup

**Module requires TWO AWS providers** (see `versions.tf`):
- Default provider - Route53, S3, CloudFront resources
- `aws.acm` provider - **MUST be us-east-1** (CloudFront ACM requirement)

Consumers must pass both providers:
```hcl
module "example" {
  source = "./terraform-module-aws-route53"
  providers = { aws.acm = aws.acm }  # us-east-1 region required
}
```

## Key Patterns & Gotchas

### Zone Indexing Pattern
All resources use `aws_route53_zone.this[0].zone_id` (note `[0]`) because zone uses `count = var.enabled ? 1 : 0`, not `for_each`.

### DNS Record Variables
- Standard records: `map(list(string))` - A, AAAA, CNAME, MX, TXT, NS, CAA
- Web redirects: `map(string)` - single redirect URL per domain
- TTL variables: `var.ttl` (3600), `var.ttl_acm` (60), `var.ttl_ns` (172800)

### Web Redirect Architecture (records_wr)

**Why CloudFront uses `custom_origin_config` not `s3_origin_config`**:
- S3 website endpoints (`redirect_all_requests_to`) don't support HTTPS origins
- Must use `origin_protocol_policy = "http-only"` (AWS limitation, not choice)
- User-Agent header (`base64sha512("REFER-SECRET-...")`) authenticates CloudFront→S3 (see `s3.tf` bucket policy)

**Certificate validation complexity** (`main.tf:records_wr_validation`):
```hcl
for_each = { for dvo in flatten([
  for cert in aws_acm_certificate.records_wr : cert.domain_validation_options
]) : dvo.domain_name => { ... } }
```
Flattens all `domain_validation_options` from all ACM certs to create unique validation records.

## Development Workflows

**⚠️ CRITICAL**: Module root cannot be validated directly. Always work from `example/` directory:

```bash
# Format code (run from module root)
terraform fmt -recursive

# Validate/plan (MUST run from example/ directory)
cd example && terraform init
cd example && terraform validate
cd example && terraform plan

# Run Go tests (requires AWS credentials)
cd test && go test -v -timeout 30m

# Run compliance tests
terraform-compliance -f compliance -p .
```

**Why example/ is required**: Module uses `configuration_aliases = [aws.acm]` which needs provider configuration only present in `example/provider.tf`.

## Testing

**Terratest** (`test/terraform_module_test.go`): Go integration tests using `example/` as fixture
**Compliance** (`compliance/features/example.feature`): Gherkin BDD for TTL policy checks

When adding features: Update both test suites + `example/main.tf` demonstration.

## Security Annotations

`tfsec` ignores are intentional for redirect-only S3 buckets (no data storage):
- `AWS002`/`AWS017` - Encryption not needed
- `AWS020`/`AWS072` - HTTP viewer protocol allowed
- `AWS045` - CloudFront logging not required
- `AWS071` - WAF not required
- `AWS077` - S3 versioning not needed

**Do not remove** without understanding these are empty redirect buckets.

## Common Errors

1. **"Provider not configured"**: Missing `providers = { aws.acm = aws.acm }` or ACM provider not in us-east-1
2. **Validation from module root fails**: Must run from `example/` directory (see Development Workflows)
3. **Wrong zone reference**: Use `this[0]` not `this` for zone resource access
4. **S3 origin errors**: CloudFront must use `custom_origin_config` for S3 website endpoints
