## Description

<!-- What does this PR change and why? -->

## Type of change

- [ ] `feat` — new feature or capability
- [ ] `fix` — bug fix
- [ ] `docs` — documentation only
- [ ] `refactor` — code change with no behavior change
- [ ] `test` — test-only change
- [ ] `chore` — build, dependencies, tooling
- [ ] Breaking change (`!` in commit type or `BREAKING CHANGE:` footer)

## Changes

<!-- List the key files/resources touched, e.g. variables.tf, main.tf, example/main.tf -->

## How to test

```bash
terraform fmt -recursive
cd example && terraform init && terraform validate && terraform plan
```

- [ ] Ran `terraform fmt -recursive`
- [ ] `terraform validate` passes from `example/`
- [ ] Added/updated a Terratest assertion in `test/terraform_module_test.go` (if applicable)
- [ ] Added/updated a compliance check in `compliance/features/example.feature` (if applicable)
- [ ] Updated `example/main.tf` to demonstrate new functionality (if applicable)
- [ ] Updated `README.md` usage examples (if applicable — the API reference table is auto-generated)

## Checklist

- [ ] Commit messages follow [Conventional Commits](../CONTRIBUTING.md#commit-message-convention)
- [ ] I reviewed the [Maintenance Matrix](../.github/copilot-instructions.md#maintenance-matrix) for related files that also need updating
