# Terraform AWS Route53 Module - AI Agent Instructions

## Architecture Overview

Reusable Terraform module for Route53 hosted zones and DNS records with an HTTPS web redirect feature (`records_wr`). Creates ONE hosted zone per invocation and manages multiple DNS records via `for_each` loops.

**Web redirect infrastructure** (`records_wr`): Single input creates a private S3 bucket (CloudFront origin placeholder only) → ACM certificate → CloudFront (with OAC + a CloudFront Function that issues the 301 redirect) → Route53 A record alias for HTTPS redirects.

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

**Why the redirect happens in a CloudFront Function, not S3 website hosting**:
- The S3 bucket (`s3.tf`) is a private placeholder origin — no objects are ever stored or served, and it has `block_public_acls`/`block_public_policy` fully enabled
- CloudFront uses Origin Access Control (OAC, SigV4 signing) to authenticate to S3; the bucket policy grants `s3:GetObject` only to the specific distribution via `aws:SourceArn` (see `s3.tf`), plus a deny-non-HTTPS statement
- A `viewer-request` CloudFront Function (`cloudfront.tf`) intercepts every request and returns a 301 to the target URL before the origin is ever contacted — the S3 origin exists only to satisfy CloudFront's requirement for one, and OAC keeps it inaccessible if the function were ever disabled

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

`tfsec` ignores are intentional for redirect-only S3 buckets and distributions (no data stored, redirect handled entirely by a CloudFront Function before the origin is reached):
- `AWS002`/`AWS017` - Encryption not needed (placeholder bucket, no data stored)
- `AWS077` - S3 versioning not needed (placeholder bucket, no objects stored)
- `AWS098` - S3 access logging not needed (placeholder bucket, no objects stored)
- `AWS020`/`AWS072` - HTTP viewer protocol allowed (CloudFront Function issues the HTTPS redirect at `viewer-request`, so `allow-all` never actually serves content over HTTP)
- `AWS021` - TLSv1.2_2021 minimum protocol version is acceptable for this use case
- `AWS045` - CloudFront access logging not required
- `AWS071` - WAF not required

**Do not remove** without understanding these are empty redirect buckets.

## Maintenance Matrix

What to update together when changing different parts of this module:

| If you change... | Also update... |
|---|---|
| A DNS record variable in `variables.tf` (new/renamed record type) | Matching resource in `main.tf`, demonstration in `example/main.tf`, assertion in `test/terraform_module_test.go`, `README.md` usage examples (not the auto-generated API table) |
| `records_wr` structure (`variables.tf`, `main.tf`) | `cert.tf`, `cloudfront.tf`, `s3.tf` (all consume `records_wr` keys), `example/main.tf`, Terratest assertions, `compliance/features/example.feature` |
| TTL variables (`ttl`, `ttl_acm`, `ttl_ns`) | Any `aws_route53_record` resource using that TTL in `main.tf`, compliance TTL policy checks in `compliance/features/example.feature` |
| `versions.tf` (provider/Terraform version bumps) | `example/provider.tf` (must satisfy the same constraints), CI workflows pinning `terraform_version` (`lint.yml`, `scheduled-test.yml`) |
| `cloudfront.tf` / `s3.tf` origin or bucket policy | `tfsec` ignore comments and their justification (do not silently drop), `compliance/features/example.feature` if a policy check depends on it |
| `outputs.tf` | `README.md` API reference is regenerated automatically by `documentation.yml` — no manual edit needed, but downstream consumers referencing output names should be considered |
| `test/go.mod` Go or dependency versions | `.github/workflows/scheduled-test.yml` `setup-go` version, `test/go.sum` (via `go mod tidy`) |
| Commit message conventions / release logic | `CONTRIBUTING.md` commit type table, `.github/workflows/release.yml` bump-detection regex |
| Anything affecting AI agent guidance | `AGENTS.md` and this file — keep both in sync, they serve different tools but describe the same repo |

## Common Errors

1. **"Provider not configured"**: Missing `providers = { aws.acm = aws.acm }` or ACM provider not in us-east-1
2. **Validation from module root fails**: Must run from `example/` directory (see Development Workflows)
3. **Wrong zone reference**: Use `this[0]` not `this` for zone resource access
4. **S3 access denied via CloudFront**: The bucket is private; access is only via OAC scoped to the distribution's `aws:SourceArn` — do not add `s3_origin_config`/website hosting or public bucket policies
