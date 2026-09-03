# AGENTS.md

Guidance for AI coding agents working in this repository. See also [.github/copilot-instructions.md](.github/copilot-instructions.md) for deeper architectural notes and [CONTRIBUTING.md](CONTRIBUTING.md) for the human contributor workflow.

## Project Overview

Reusable Terraform module (published to the [Terraform Registry](https://registry.terraform.io/modules/locus313/aws-route53/module/latest) as `locus313/route53/aws`) that provisions a single AWS Route53 hosted zone plus DNS records. Its standout feature, `records_wr`, provisions a complete HTTPS web-redirect stack (S3 → CloudFront → ACM → Route53 alias) from a single input. Required Terraform and provider versions live in [versions.tf](versions.tf) — do not hardcode them elsewhere.

## Repository Structure

| Path | Purpose |
|------|---------|
| [main.tf](main.tf) | Hosted zone + all `aws_route53_record` resources (`for_each` per record type) |
| [cert.tf](cert.tf) | ACM certificate resources for `records_wr` (must use `aws.acm` provider, us-east-1) |
| [cloudfront.tf](cloudfront.tf) | CloudFront distributions fronting the redirect S3 buckets |
| [s3.tf](s3.tf) | S3 buckets configured for website redirection, bucket policy gated by CloudFront User-Agent secret |
| [variables.tf](variables.tf) | All module inputs — `map(list(string))` for standard records, `map(string)` for `records_wr` |
| [outputs.tf](outputs.tf) | Module outputs (zone id, name servers, etc.) |
| [versions.tf](versions.tf) | Provider/version constraints, declares the `aws.acm` configuration alias |
| [example/](example/) | Working example consumer — the **only** place `terraform validate`/`plan` can run (see Build & Run) |
| [test/](test/) | Go Terratest integration tests using `example/` as the fixture |
| [compliance/](compliance/) | `terraform-compliance` Gherkin feature files (BDD policy checks) |
| [.github/instructions/](.github/instructions/) | Path-scoped Copilot instructions (Terraform, Go, security, CI) |
| [.github/agents/](.github/agents/) | Custom Copilot agent personas (Terraform planning/implementation/review, Terratest, AWS, GitHub Actions) |
| [.github/skills/](.github/skills/) | Bundled Copilot skills (AWS cost/Well-Architected review, CodeQL, Dependabot, secret scanning, etc.) |

## Tech Stack

- **IaC**: Terraform >= 1.0, AWS provider >= 4.0 (see [versions.tf](versions.tf))
- **Testing**: Go (`test/go.mod` — check the `go` directive for the exact version), [Terratest](https://terratest.gruntwork.io/), `terraform-compliance`
- **CI**: GitHub Actions (`.github/workflows/`)
- **Docs**: `terraform-docs` auto-injects the API reference table into `README.md` on every PR (see [.github/workflows/documentation.yml](.github/workflows/documentation.yml)) — never hand-edit the generated table

## Build & Run

**The module root cannot be validated directly** — it uses `configuration_aliases = [aws.acm]`, which is only satisfied by the provider config in `example/provider.tf`.

```bash
# Format (run from repo root)
terraform fmt -recursive

# Validate / plan — MUST run from example/
cd example
terraform init -input=false
terraform validate
terraform plan
```

## Testing

```bash
# Terratest integration tests (requires AWS credentials — applies real resources)
cd test
go test -v -timeout 30m

# Compliance (BDD policy) tests — requires an example/ plan
cd example && terraform init -backend=false && terraform plan -out=tfplan
terraform-compliance -f compliance/features -p .
```

Terratest and compliance tests also run nightly via [.github/workflows/scheduled-test.yml](.github/workflows/scheduled-test.yml) (not on every PR, since they require AWS credentials and apply real infrastructure). [.github/workflows/lint.yml](.github/workflows/lint.yml) runs `terraform fmt -check` and `terraform validate` (against `example/`) on every PR.

## Key Patterns and Conventions

- Zone resource uses `count`, not `for_each` — always reference it as `aws_route53_zone.this[0]`.
- Standard DNS record variables are `map(list(string))`; `records_wr` is `map(string)` (one redirect URL per domain).
- CloudFront origins for `records_wr` use `custom_origin_config` with `origin_protocol_policy = "http-only"` — S3 website endpoints cannot serve HTTPS origins, so this is an AWS constraint, not a stylistic choice.
- ACM certificate validation records are built by flattening `domain_validation_options` across all `aws_acm_certificate.records_wr` instances (see the `for_each` in [main.tf](main.tf)) to produce one validation record per unique domain.
- `tfsec` ignores in `s3.tf`/`cloudfront.tf` (e.g. `AWS002`, `AWS020`, `AWS045`, `AWS071`, `AWS077`) are intentional for these empty, redirect-only resources — do not remove them without understanding why (see [.github/copilot-instructions.md](.github/copilot-instructions.md#security-annotations)).

## CI/CD

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| [lint.yml](.github/workflows/lint.yml) | PR to `main` | `terraform fmt -check`, `terraform validate` in `example/` |
| [documentation.yml](.github/workflows/documentation.yml) | PR to `main` | Regenerates the README API reference table via `terraform-docs` |
| [scheduled-test.yml](.github/workflows/scheduled-test.yml) | Nightly cron + manual | Terratest + terraform-compliance against real AWS resources |
| [release.yml](.github/workflows/release.yml) | Push to `main` touching `**.tf` (excluding `example/`) | SemVer bump + tag + GitHub Release, derived from [Conventional Commits](https://www.conventionalcommits.org/) |

Commit messages **must** follow Conventional Commits — the release workflow parses them to decide the version bump. See [CONTRIBUTING.md](CONTRIBUTING.md#commit-message-convention) for the full type table.

## Adding a New DNS Record Type

1. Add the variable in [variables.tf](variables.tf) (`map(list(string))`, default `{}`).
2. Add the `aws_route53_record` resource with matching `for_each` in [main.tf](main.tf), referencing `aws_route53_zone.this[0].zone_id`.
3. Add a matching TTL variable if the record type needs a non-default TTL.
4. Demonstrate the new record type in [example/main.tf](example/main.tf).
5. Add/extend a Terratest assertion in [test/terraform_module_test.go](test/terraform_module_test.go).
6. Add a compliance check in [compliance/features/example.feature](compliance/features/example.feature) if a policy applies (e.g. TTL bounds).
7. Update [README.md](README.md) usage examples — the API reference table itself is auto-generated, do not hand-edit it.

## Changelog & Releases

There is no committed `CHANGELOG.md` — the [release workflow](.github/workflows/release.yml) generates release notes from commit history and publishes them as the body of each [GitHub Release](https://github.com/locus313/terraform-module-aws-route53/releases). [CHANGELOG.md](CHANGELOG.md) at the repo root is a pointer to that history.

## Common Pitfalls

1. **"Provider not configured"** — missing `providers = { aws.acm = aws.acm }` in the consuming module, or the aliased provider isn't pinned to `us-east-1`.
2. **Validation fails at repo root** — must run `terraform init`/`validate`/`plan` from `example/`, not the module root.
3. **Wrong zone reference** — use `aws_route53_zone.this[0]`, not `aws_route53_zone.this`.
4. **CloudFront/S3 origin errors** — must use `custom_origin_config`, not `s3_origin_config`, for S3 website endpoints.
5. **Editing the generated API reference table in README.md** — it's overwritten by `terraform-docs` on the next PR; edit variable/output descriptions in `.tf` files instead.
