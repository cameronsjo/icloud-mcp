# ADR 0001: Initial Architecture

## Status

Accepted

## Context

We need an MCP server that exposes iCloud Reminders as tools. iCloud Reminders are stored as VTODO entries on Apple's CalDAV server.

## Decision

- **Language:** Go — single binary deployment, strong stdlib for HTTP/XML
- **Protocol:** Raw CalDAV over HTTP (PROPFIND, REPORT, PUT, DELETE) — no heavy CalDAV library needed
- **Authentication:** HTTP Basic Auth with Apple app-specific passwords
- **MCP:** Use the Go MCP SDK for stdio transport
- **Structure:** `cmd/` for entrypoint, `internal/` for caldav, mcp, and vtodo packages

## Consequences

- Simple deployment: single binary, no runtime dependencies
- CalDAV XML handling requires careful namespace management
- App-specific passwords must be generated manually by users
