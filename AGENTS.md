# icloud-mcp

MCP server for iCloud Reminders via CalDAV. Go project.

## Commands

```bash
make build    # Build binary to bin/
make check    # Run golangci-lint
make test     # Run test suite
make help     # Show all targets
```

## Project Structure

```
icloud-mcp/
├── cmd/            # Application entrypoints
├── internal/       # Private packages
│   ├── caldav/     # CalDAV client (PROPFIND, REPORT, PUT, DELETE)
│   ├── mcp/        # MCP server and tool handlers
│   └── vtodo/      # VTODO parsing and generation
├── bin/            # Build output (gitignored)
├── docs/           # Documentation
│   └── adr/        # Architecture Decision Records
└── Makefile        # Task runner
```

## Conventions

- Conventional Commits: `type(scope): description`
- All code MUST have type annotations
- Structured logging to stdout
- Environment variables for configuration: `ICLOUD_EMAIL`, `ICLOUD_APP_PASSWORD`
- CalDAV endpoint: `https://caldav.icloud.com`

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
