# setup-oracle-instant-client-action

[![CI](https://github.com/iamazeem/setup-oracle-instant-client-action/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamAzeem/setup-oracle-instant-client-action/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-darkgreen.svg?style=flat-square)](https://github.com/iamAzeem/setup-oracle-instant-client-action/blob/master/LICENSE)
![Release](https://img.shields.io/github/v/release/iamAzeem/setup-oracle-instant-client-action?style=flat-square)

[GitHub Action](https://docs.github.com/en/actions) to set up (download and
install) the [Oracle Instant
Client](https://www.oracle.com/database/technologies/instant-client/downloads.html).

Supports Linux, macOS, and Windows runners.

## Usage

### Outputs

|     Output     | Description                                    |
| :------------: | :--------------------------------------------- |
| `install-path` | Absolute install path of Oracle Instant Client |

### Example

```yml
- name: Set up Oracle Instant Client
  uses: iamazeem/setup-oracle-instant-client-action@v1
```

See [CI workflow](./.github/workflows/ci.yml) for a detailed example with
[gvenzl/setup-oracle-free](https://github.com/gvenzl/setup-oracle-free).

## Contribute

Please [create
issues](https://github.com/iamazeem/setup-oracle-instant-client-action/issues/new/choose)
to report bugs or propose new features and enhancements.

PRs are always welcome. Please follow this workflow for submitting PRs:

- [Fork](https://github.com/iamazeem/setup-oracle-instant-client-action/fork)
  the repo.
- Check out the latest `main` branch.
- Create a `feature` or `bugfix` branch from `main`.
- Commit and push changes to your forked repo.
- Make sure to add/update tests. See [CI](./.github/workflows/ci.yml).
- Lint and fix [Bash](https://www.gnu.org/software/bash/manual/bash.html) issues
  with [shellcheck](https://www.shellcheck.net/) online or with
  [vscode-shellcheck](https://github.com/vscode-shellcheck/vscode-shellcheck)
  extension.
- Lint and fix [README](README.md) Markdown issues with
  [vscode-markdownlint](https://github.com/DavidAnson/vscode-markdownlint)
  extension.
- Submit the PR.

## License

[MIT](LICENSE)
