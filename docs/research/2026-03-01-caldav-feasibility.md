# CalDAV Feasibility Research

**Date:** 2026-03-01
**Status:** Unresolved — probe test needed before committing to an approach

## Summary

We investigated whether iCloud Reminders can be managed via CalDAV VTODO. The answer is **uncertain** — there is credible evidence both for and against. A 10-minute probe script against a real iCloud account will resolve the question definitively.

## Background

iCloud Reminders are (or were) stored as VTODO entries on Apple's CalDAV server (`caldav.icloud.com`). The original plan was to build an MCP server that authenticates with an app-specific password and exposes CRUD operations on these VTODO entries.

## Finding 1: Apple May Have Killed CalDAV VTODO

Starting with iOS 13 / macOS Catalina (2019), Apple introduced a new Reminders app that uses a proprietary, non-CalDAV format. When a user "upgrades" their Reminders (a one-time, irreversible migration prompted on first launch):

- All VTODO-only calendar collections are **migrated off CalDAV** into a proprietary silo
- The CalDAV server **no longer exposes those VTODO collections** for that account
- There is **no way to revert** to the CalDAV-compatible format
- There is **no way to create new CalDAV-compatible VTODO task lists** after the upgrade

The `python-caldav` library maintainers closed their iCloud compatibility issue in March 2021, stating "no more work is planned on iCloud support" and documenting "no support for freebusy-requests, tasks or journals."

**Sources:**

- [BusyMac: Reminders in iOS 13 Drops CalDAV Support](https://www.busymac.com/docs/faqs/112990-reminders-in-ios-13-and-macos-catalina-drops-support-for-caldav/)
- [python-caldav Issue #3](https://github.com/python-caldav/caldav/issues/3) — closed 2021
- [Nextcloud Issue #17190](https://github.com/nextcloud/server/issues/17190)

## Finding 2: Multiple Active Projects Claim It Works

Contradicting Finding 1, several actively maintained projects (2025-2026) claim CalDAV VTODO works with iCloud:

| Project | Language | Stars | Last Active | VTODO CRUD | iCloud Tested |
|---------|----------|------:|------------|------------|---------------|
| [`kevmarchant/go-icloud-caldav`](https://github.com/kevmarchant/go-icloud-caldav) | Go | 0 | 2025-09 | Yes | Yes |
| [`pimutils/vdirsyncer`](https://github.com/pimutils/vdirsyncer) | Python | 1,783 | 2026-02 | Yes | Yes |
| [`pimutils/todoman`](https://github.com/pimutils/todoman) | Python | 569 | 2026-02 | Yes | Yes (via vdirsyncer) |
| [`natelindev/tsdav`](https://github.com/natelindev/tsdav) | TypeScript | 332 | 2026-02 | Yes | Yes |
| [`emersion/go-webdav`](https://github.com/emersion/go-webdav) | Go | 458 | 2025-12 | Yes (generic) | Not iCloud-specific |

**Possible explanations for the contradiction:**

1. These projects may work against accounts that never upgraded Reminders (unlikely for active users)
2. Apple may have partially restored CalDAV VTODO access after the initial 2019 removal
3. Some projects may claim iCloud support based on VEVENT testing, not VTODO specifically
4. The upgrade behavior may vary by region, account age, or Apple ID type

**This is unresolved.** Only a live test against a real upgraded iCloud account will answer it.

## Finding 3: CalDAV Discovery Flow Works

The PROPFIND discovery chain is well-documented and proven in multiple Go projects:

### Step 1: Get User Principal

```http
PROPFIND / HTTP/1.1
Host: caldav.icloud.com
Content-Type: application/xml; charset=utf-8
Authorization: Basic <base64(email:app-specific-password)>
Depth: 0

<?xml version="1.0" encoding="UTF-8"?>
<d:propfind xmlns:d="DAV:">
  <d:prop>
    <d:current-user-principal/>
  </d:prop>
</d:propfind>
```

Returns a principal path like `/200385701/principal/`.

### Step 2: Get Calendar Home Set

```http
PROPFIND /200385701/principal/ HTTP/1.1
Host: caldav.icloud.com
Depth: 0
```

Request `calendar-home-set` property. Response includes the **actual endpoint** on a different hostname: `https://p34-caldav.icloud.com:443/200385701/calendars/` (the `pXX` prefix varies per account).

### Step 3: List Calendars

```http
PROPFIND /200385701/calendars/ HTTP/1.1
Host: p34-caldav.icloud.com
Depth: 1
```

Returns all calendar collections with `displayname`, `calendar-color`, `supported-calendar-component-set` (VEVENT, VTODO, etc.).

### Key Points

- Initial contact at `caldav.icloud.com`, all subsequent operations on discovered `pXX-caldav.icloud.com` host
- The numeric ID (e.g., `200385701`) is account-specific, discovered via PROPFIND
- `.well-known/caldav` endpoint also works (returns 301/302 redirect)
- All requests require Authorization header — unauthenticated returns 401

## Finding 4: Go MCP SDK Is Mature

The official Go MCP SDK is the clear choice:

| Attribute | Value |
|-----------|-------|
| **Import** | `github.com/modelcontextprotocol/go-sdk/mcp` |
| **Version** | v1.4.0 (Feb 27, 2026) |
| **Maintainers** | Google Go team + Anthropic |
| **Stars** | ~4,000 |
| **Transports** | stdio, HTTP+streaming, SSE, in-memory |
| **License** | MIT |

Previously `mark3labs/mcp-go` (8.3k stars) was the de facto SDK, but GitHub itself migrated to the official SDK. The official SDK reached v1.0 in mid-2025 and has stable semver guarantees.

### Minimal Server Example

```go
package main

import (
    "context"
    "log"

    "github.com/modelcontextprotocol/go-sdk/mcp"
)

type GreetInput struct {
    Name string `json:"name" jsonschema:"the name of the person to greet"`
}

func main() {
    server := mcp.NewServer(
        &mcp.Implementation{Name: "greeter", Version: "v1.0.0"},
        nil,
    )

    mcp.AddTool(server, &mcp.Tool{
        Name:        "greet",
        Description: "Greet someone by name",
    }, func(ctx context.Context, req *mcp.CallToolRequest, input GreetInput) (*mcp.CallToolResult, any, error) {
        return &mcp.CallToolResult{
            Content: []mcp.Content{
                &mcp.TextContent{Text: "Hello, " + input.Name + "!"},
            },
        }, nil, nil
    })

    if err := server.Run(context.Background(), &mcp.StdioTransport{}); err != nil {
        log.Fatal(err)
    }
}
```

Struct tags on the input type drive JSON Schema generation. `server.Run()` blocks on stdio, reading JSON-RPC from stdin and writing to stdout.

### Claude Code Integration

```json
{
  "mcpServers": {
    "icloud-mcp": {
      "command": "/path/to/icloud-mcp",
      "args": []
    }
  }
}
```

## Finding 5: Alternative Approach — CloudKit API

[`tarekbecker/icloud-reminders-cli`](https://github.com/tarekbecker/icloud-reminders-cli) (Go, Feb 2026) bypasses CalDAV entirely and talks to Apple's CloudKit API directly. This is the same private API that Apple's own Reminders app uses.

| Attribute | CalDAV VTODO | CloudKit API |
|-----------|-------------|-------------|
| **Protocol** | RFC 4791 (standard) | Undocumented private API |
| **Auth** | App-specific password, Basic Auth | 2FA flow, session tokens, trust tokens |
| **Stability** | Standards-based, unlikely to break | Could break with any iOS/macOS update |
| **Features** | Basic VTODO fields | Full Reminders features (subtasks, etc.) |
| **Complexity** | Low (HTTP + XML) | High (auth flows, session management) |
| **Proven in Go** | `kevmarchant/go-icloud-caldav` | `tarekbecker/icloud-reminders-cli` |

## Finding 6: Existing Go CalDAV Libraries

If CalDAV VTODO works, we have two options for the CalDAV layer:

### Option A: `kevmarchant/go-icloud-caldav`

- Purpose-built for iCloud, has VTODO CRUD (`CreateTodo`, `UpdateTodo`, `DeleteTodo`)
- Handles iCloud XML namespace quirks, connection pooling, retry with backoff
- Zero external dependencies (pure Go, implements CalDAV from scratch)
- 82.4% test coverage
- **Risk:** 0 stars, single maintainer, could go unmaintained

### Option B: `emersion/go-webdav` + `emersion/go-ical`

- Ecosystem standard (458 stars, many dependents)
- Generic RFC 4791 implementation, not iCloud-specific
- Would need iCloud-specific auth handling, endpoint discovery, VTODO convenience layer
- **Risk:** More work to adapt to iCloud quirks, but more stable foundation

### Option C: Raw HTTP

- Our original plan — `net/http` + `encoding/xml`
- Full control, no dependencies beyond the MCP SDK
- CalDAV is just HTTP + XML, the protocol is simple enough to implement directly
- Reference `kevmarchant/go-icloud-caldav` for iCloud-specific XML quirks
- **Risk:** Most work upfront, but fewest surprises long-term

## Authentication Notes

- App-specific passwords are **mandatory** (even without 2FA, though 2FA must be enabled to generate them)
- Generated at [appleid.apple.com](https://appleid.apple.com) > Sign-In and Security > App-Specific Passwords
- HTTP Basic Auth: `Authorization: Basic <base64(appleid:app-specific-password)>`
- Standard `Content-Type: application/xml; charset=utf-8` header
- No special Apple-specific headers required
- Password grants broad access (calendars, contacts, mail) — no per-service scoping

## Recommended Next Step: Probe Test

Write a ~50-line Go script that:

1. Authenticates against `caldav.icloud.com` with app-specific password
2. Runs the PROPFIND discovery chain (Steps 1-3 above)
3. Lists all calendars and their `supported-calendar-component-set`
4. Reports whether any collections support VTODO

This definitively answers whether CalDAV VTODO is viable for the user's iCloud account. Takes ~10 minutes to write and run.

### If VTODO collections exist → Path A (CalDAV)

Build the MCP server using CalDAV VTODO. Choose between raw HTTP, `go-icloud-caldav`, or `go-webdav` as the CalDAV layer.

### If no VTODO collections → Decision point

1. **Pivot to CloudKit API** — reference `tarekbecker/icloud-reminders-cli`, accept the fragility
2. **Pivot to Calendar Events (VEVENT)** — CalDAV VEVENT definitely works, but changes the product scope
3. **Abandon** — if neither CalDAV nor CloudKit is acceptable

## Open Questions

1. Has the user's iCloud account "upgraded" Reminders? (probe test answers this)
2. If CalDAV VTODO works, which Go library approach is best? (depends on how much iCloud-specific quirk handling we need)
3. If CalDAV VTODO is dead, is the CloudKit API acceptable despite being undocumented?
4. Should we support both backends with a pluggable interface? (probably over-engineering for v0.1)
