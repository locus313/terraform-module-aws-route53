# Coding standards

Read during review. Mechanical rules belong in CI, not here.

- Examples, docs and tests use `example.com` (and its subdomains) for domains; never a real customer or third-party domain.
- Terraform `variable` validations reference only their own variable (Terraform 1.0 floor in `versions.tf`).
- Tests that depend on rendering a template render it through real Terraform, not a re-implementation.
