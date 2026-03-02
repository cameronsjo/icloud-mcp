# Contributing to icloud-mcp

## Code of Conduct

Be respectful, constructive, and professional.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/<you>/icloud-mcp`
3. Install dependencies: `go mod download`
4. Create a branch: `git checkout -b feat/my-feature`

## Development Setup

- Go 1.23+
- golangci-lint for linting

```bash
make check    # Lint
make test     # Test
make build    # Build
```

## Commit Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Pull Requests

- Keep PRs focused on a single change
- Include tests for new functionality
- Ensure `make check` and `make test` pass
- Reference related issues with closing keywords (`Closes #123`)
