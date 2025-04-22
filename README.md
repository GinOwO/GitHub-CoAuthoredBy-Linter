# Co-authored-by Linter

[![GitHub Workflow Status](https://github.com/GinOwO/GitHub-CoAuthoredBy-Linter/actions/workflows/main.yaml/badge.svg)](https://github.com/GinOwO/GitHub-CoAuthoredBy-Linter/actions/workflows/main.yaml)
[![GitHub release](https://img.shields.io/github/release/GinOwO/GitHub-CoAuthoredBy-Linter.svg?style=flat-square)](https://github.com/GinOwO/GitHub-CoAuthoredBy-Linter/releases/latest)
[![GitHub marketplace](https://img.shields.io/badge/marketplace-CoAuthoredBy-blue?logo=github&style=flat-square)](https://github.com/marketplace/actions/co-authored-by-linter)

GitHub action to ensure proper formatting of `Co-authored-by:` lines in commit messages.
Checks for missing emails, incorrect casing, and GitHub usernames.
Prints Warning in case of minor/potential issues like single-word names and github no-reply emails \(strict mode to fail all cases\).

Inspired by this [issue](https://github.com/open-source-ideas/ideas/issues/414).

## Usage

Add to your workflow YAML:
```yaml
jobs:
  co-authored-by-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: GinOwO/GitHub-CoAuthoredBy-Linter@latest
        with:
          BASE_REF: ${{ github.base_ref }}
          STRICT_MODE: 'false'
```

Example:
```yaml
name: Check Co-authored-by
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  co-authored-by-check:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Check Co-authored-by
        uses: GinOwO/GitHub-CoAuthoredBy-Linter@1.0.0
        with:
          BASE_REF: ${{ github.base_ref }}
          STRICT_MODE: 'false'
```

## Inputs

- `STRICT_MODE` (optional): Enable strict mode (`true` or `false`).
  - Default: `false`
  
- `BASE_REF` (optional): Specify the branch to check against.
  - Default: `refs/heads/main`

## Outputs
- `CO_AUTHORED_BY`: The co-authored-by lines found in the commit message.

- `ISSUES`: The issues found in the commit message.

- `STATUS`: The status of the check.

## License

This project is licensed under the GPLv3 License. See the [LICENSE](LICENSE) file for details.