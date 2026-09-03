# Changelog

This project does not maintain a hand-written changelog file. Every release is created
automatically by [.github/workflows/release.yml](.github/workflows/release.yml) when
`*.tf` files change on `main`, using [Conventional Commits](https://www.conventionalcommits.org/)
to determine the version bump (`feat` → minor, `fix` → patch, `feat!`/`BREAKING CHANGE:` → major).

**See the full history here: [GitHub Releases](https://github.com/locus313/terraform-module-aws-route53/releases)**

For the commit conventions that drive changelog generation, see
[CONTRIBUTING.md](CONTRIBUTING.md#commit-message-convention).
