# Gexec: Infra

[![General Workflow](https://github.com/gexec/gexec-infra/actions/workflows/general.yml/badge.svg)](https://github.com/gexec/gexec-infra/actions/workflows/general.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/81aa598431ad486ebcca999cca619520)](https://app.codacy.com/gh/gexec/gexec-infra/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade) [![Discord](https://img.shields.io/discord/1335976189025849395)](https://discord.gg/Yda8rD4ZkJ)

This repository defines the infrastructure used by this project, including setup
of subdomains and object storage buckets and what else is needed.

## Prerequisites

We use [mise][mise] to manage all required tools and their versions. Install it
by following the [official installation instructions][mise-install], then run
the following commands inside the repository to activate mise and install all
tools defined in `mise.toml`:

```console
mise trust
mise install
```

## Usage

We are using [Terraform][terraform] to provision all related parts. Every change
have to be submitted via pull requests, after merging the pull request the
changes are getting applied automatically by our CI system. It is possible to
execute everything from a workstation, but it's encouraged to keep it in the
hands of our CI system.

### Variables

To get access to the secrets you got to install the 1Password CLI, you can
choose on your own if you export the `OP_SERVICE_ACCOUNT_TOKEN` environment
variable or simply execute `op signin`.

```console
cat << EOF > mise.local.toml
[env]
CLOUDFLARE_EMAIL = "$(op read op://Gexec/Cloudflare/username)"
CLOUDFLARE_API_KEY = "$(op read op://Gexec/Cloudflare/token)"

AWS_ACCESS_KEY_ID = "$(op read op://Gexec/Terraform/username)"
AWS_SECRET_ACCESS_KEY = "$(op read op://Gexec/Terraform/password)"
EOF
```

### Deployment

```console
terraform -chdir=terraform/ init
terraform -chdir=terraform/ plan
terraform -chdir=terraform/ apply
```

## Security

If you find a security issue please contact
[gexec@webhippie.de](mailto:gexec@webhippie.de) first.

## Contributing

Generally we are following [conventional commits][commits] when we apply
changes. That way we are able to generate proper changelogs for every release.
Please use always pull requests to integrate new functionalities or to fix
issues.

For the release process we are following [semantic versioning][semver] which
clearly indicates if a new version just resolves bugs, includes new features or
even includes breaking changes.

After installing the tools via `mise install` as described above set up the
pre-commit hooks so they run automatically on every commit:

```console
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

> `pre-commit` is managed by mise and will be available after `mise install`.

If you have changed something on the source you should simply commit following
the mentioned conventions:

```console
git checkout -b feat/new-feature
git add --all
git commit -m 'feat: added awesome new feature'
git push --set-upstream origin feat/new-feature
```

After pushing your changes into the Git repository you should create a pull
request on GitHub. If the pull request have been merged and everything built
fine it will also create automatically a new release at least once a week.

## Authors

-   [Thomas Boerger](https://github.com/tboerger)

## License

Apache-2.0

## Copyright

```console
Copyright (c) 2025 Thomas Boerger <thomas@webhippie.de>
```

[terraform]: https://www.terraform.io/
[mise]: https://mise.jdx.dev/
[mise-install]: https://mise.jdx.dev/getting-started.html
[commits]: https://www.conventionalcommits.org/en/v1.0.0/
[semver]: https://semver.org/
