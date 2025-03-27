# Gexec: Infra

[![General Workflow](https://github.com/gexec/gexec-infra/actions/workflows/general.yml/badge.svg)](https://github.com/gexec/gexec-infra/actions/workflows/general.yml) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/81aa598431ad486ebcca999cca619520)](https://app.codacy.com/gh/gexec/gexec-infra/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade) [![Discord](https://img.shields.io/discord/1335976189025849395)](https://discord.gg/Yda8rD4ZkJ)

This repository defines the infrastructure used by this project, including setup
of subdomains and object storage buckets and what else is needed.

## Usage

We are using [Terraform][terraform] to provision all related parts. Every change
have to be submitted via pull requests, after merging the pull request the
changes are getting applied automatically by our CI system. It is possible to
execute everything from a workstation, but it's encouraged to keep it in the
hands of our CI system.

### Variables

To get access to the secrets you got to install the 1Password CLI and export the
environment variable `OP_SERVICE_ACCOUNT_TOKEN` which you can find in our shared
store, after that you can simply execute the commands below.

```console
cat << EOF >| .envrc
use flake . --impure

export CLOUDFLARE_EMAIL=$(op read op://Gexec/Cloudflare/username)
export CLOUDFLARE_API_KEY=$(op read op://Gexec/Cloudflare/token)

export AWS_ACCESS_KEY_ID=$(op read op://Gexec/Terraform/username)
export AWS_SECRET_ACCESS_KEY=$(op read op://Gexec/Terraform/password)
EOF

direnv allow
```

### Deployment

```console
bin/terraform init
bin/terraform plan
bin/terraform apply
```

## Security

If you find a security issue please contact
[gexec@webhippie.de](mailto:gexec@webhippie.de) first.

## Contributing

Fork -> Patch -> Push -> Pull Request

## Authors

-   [Thomas Boerger](https://github.com/tboerger)

## License

Apache-2.0

## Copyright

```console
Copyright (c) 2025 Thomas Boerger <thomas@webhippie.de>
```

[terraform]: https://www.terraform.io/
