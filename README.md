# icloud-mcp

MCP server that manages iCloud Reminders via the CalDAV protocol. Authenticates with an app-specific password and exposes CRUD operations as MCP tools.

## Getting Started

### Prerequisites

- Go 1.23+
- Apple ID with an [app-specific password](https://support.apple.com/en-us/102654)

### Configuration

Set environment variables:

```bash
export ICLOUD_EMAIL="your@apple.id"
export ICLOUD_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

### Build

```bash
make build
```

### Run

```bash
./bin/icloud-mcp
```

### MCP Tools

| Tool | Description |
|------|-------------|
| `reminders_list_lists` | List all Reminder lists |
| `reminders_list` | List reminders in a specific list |
| `reminders_create` | Create a new reminder |
| `reminders_complete` | Mark a reminder as completed |
| `reminders_delete` | Delete a reminder |

## Development

```bash
make check    # Run linting
make test     # Run tests
make build    # Build binary
```

## License

MIT
