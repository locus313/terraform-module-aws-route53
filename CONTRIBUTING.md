# Contributing to AWS Route53 Terraform Module

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Commit Message Convention](#commit-message-convention)
- [Development Workflow](#development-workflow)
- [Running Tests](#running-tests)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to create a welcoming environment for all contributors.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-module-aws-route53.git
   cd terraform-module-aws-route53
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

## Commit Message Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) to automate versioning and changelog generation. **All commits must follow this format:**

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

| Type | Description | Version Bump | Example |
|------|-------------|--------------|---------|
| `feat:` | New feature or capability | **MINOR** (1.2.0 → 1.3.0) | `feat: add Route53 health check support` |
| `fix:` | Bug fix | **PATCH** (1.2.0 → 1.2.1) | `fix: correct S3 bucket policy for redirects` |
| `feat!:` | Breaking change (with `!`) | **MAJOR** (1.2.0 → 2.0.0) | `feat!: change records_wr variable structure` |
| `docs:` | Documentation only | **PATCH** | `docs: update README examples` |
| `chore:` | Build, dependencies, tools | **PATCH** | `chore: update terraform version constraint` |
| `refactor:` | Code refactoring | **PATCH** | `refactor: simplify CloudFront origin config` |
| `test:` | Adding or updating tests | **PATCH** | `test: add compliance test for CAA records` |
| `style:` | Code style/formatting | **PATCH** | `style: run terraform fmt` |
| `perf:` | Performance improvement | **PATCH** | `perf: optimize ACM certificate lookup` |

### Breaking Changes

Breaking changes can be indicated in two ways:

**Option 1: Using `!` in the type**
```bash
git commit -m "feat!: require AWS provider >= 5.0"
```

**Option 2: Using `BREAKING CHANGE:` footer**
```bash
git commit -m "feat: redesign records_wr structure

BREAKING CHANGE: records_wr now accepts an object with redirect_url
and redirect_protocol fields instead of a simple string"
```

### Commit Message Examples

**Good commit messages:**

```bash
# Feature addition (minor bump)
git commit -m "feat: add support for DNSSEC configuration"
git commit -m "feat(cloudfront): add custom SSL certificate support"

# Bug fix (patch bump)
git commit -m "fix: resolve race condition in ACM validation"
git commit -m "fix(s3): correct bucket policy for CloudFront access"

# Documentation (patch bump)
git commit -m "docs: add migration guide for v2.0"
git commit -m "docs(readme): clarify provider configuration requirements"

# Breaking change (major bump)
git commit -m "feat!: remove deprecated ttl_default variable"

# Breaking change with detailed explanation
git commit -m "refactor: change module output structure

BREAKING CHANGE: Outputs are now nested under zone and records objects.
Users must update their output references from
this_route53_zone_zone_id to this.zone.id"
```

**Bad commit messages:**

```bash
# ❌ No type prefix
git commit -m "added new feature"

# ❌ Not descriptive
git commit -m "fix: fixes"

# ❌ Wrong format
git commit -m "Fixed the bug with CloudFront"
```

### Scope Guidelines (Optional)

Scopes help categorize changes within the module:

- `dns` - DNS record related changes
- `cloudfront` - CloudFront distribution changes
- `acm` - ACM certificate changes
- `s3` - S3 bucket changes
- `redirect` or `records_wr` - Web redirect feature changes
- `ci` - CI/CD workflow changes
- `test` - Test infrastructure changes

Example: `feat(dns): add support for SRV records`

## Development Workflow

### 1. Make Your Changes

- Edit Terraform files following existing patterns
- Use `for_each` loops for dynamic resources
- Add inline comments for complex logic
- Include `tfsec` ignore comments with explanations where needed

### 2. Format Your Code

```bash
# Format all Terraform files
terraform fmt -recursive
```

### 3. Validate Your Changes

```bash
# Initialize and validate
terraform init
terraform validate

# Test with example configuration
cd example
terraform init
terraform plan
```

### 4. Run Tests

```bash
# Run Terratest integration tests (requires AWS credentials)
cd test
go test -v -timeout 30m

# Run compliance tests
cd ..
terraform-compliance -f compliance -p .
```

### 5. Update Documentation

If your change affects usage:
- Update `README.md` with new examples
- Update variable descriptions in `variables.tf`
- Add or update compliance tests if adding policy requirements
- Update the example in `example/main.tf` if demonstrating new features

## Running Tests

### Prerequisites

- AWS credentials configured (for Terratest)
- Terraform >= 1.0
- Go >= 1.19 (for Terratest)
- terraform-compliance installed (for compliance tests)

### Integration Tests

```bash
cd test
go test -v -timeout 30m
```

This will:
1. Initialize Terraform with the example configuration
2. Apply the configuration
3. Verify outputs
4. Destroy all resources

### Compliance Tests

```bash
terraform-compliance -f compliance -p .
```

This validates policy compliance like TTL values and resource configurations.

### Manual Testing

```bash
cd example
terraform init
terraform plan
# Review the plan carefully
terraform apply
# Test functionality
terraform destroy
```

## Pull Request Process

1. **Ensure all tests pass** locally before creating a PR
2. **Follow commit message conventions** for all commits
3. **Update documentation** if you're changing functionality
4. **Create a Pull Request** against the `main` branch with:
   - Clear title following conventional commit format
   - Description of what changed and why
   - Screenshots or output if relevant
   - Reference any related issues

### PR Title Format

PR titles should also follow conventional commit format:

```
feat: add support for Route53 health checks
fix: correct CloudFront origin configuration  
docs: improve web redirect documentation
```

The PR title becomes a commit message when squashed, so it's important for versioning.

### Review Process

1. Automated checks will run (linting, validation)
2. Maintainers will review your code
3. Address any feedback or requested changes
4. Once approved, your PR will be merged

### After Merge

When your PR is merged to `main` and includes changes to `*.tf` files:
1. The release workflow automatically runs
2. A new version is tagged based on commit messages
3. A GitHub release is created with an auto-generated changelog
4. Your contribution is included in the release notes!

## Questions?

If you have questions about contributing, feel free to:
- Open an issue for discussion
- Ask in your pull request
- Reach out to the maintainers

Thank you for contributing! 🎉
