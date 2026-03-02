# Existing Projects Survey

**Date:** 2026-03-01
**Purpose:** Catalog projects that interact with iCloud Reminders or CalDAV VTODO, as reference implementations and feasibility evidence.

## Go Projects

### `kevmarchant/go-icloud-caldav` — iCloud CalDAV Client with VTODO CRUD

- **URL:** https://github.com/kevmarchant/go-icloud-caldav
- **Stars:** 0 | **Last active:** 2025-09 | **Version:** v0.3.0
- **VTODO:** Yes — `CreateTodo()`, `UpdateTodo()`, `DeleteTodo()` in `todo_crud.go`
- **iCloud tested:** Yes
- **Dependencies:** Zero (pure Go, implements CalDAV from scratch)
- **Test coverage:** 82.4%
- **Notable:** `ParsedTodo` struct with UID, Summary, Description, Status, Due, Completed, PercentComplete, Priority, Categories. Handles iCloud XML namespace quirks, connection pooling, retry with exponential backoff, incremental sync (RFC 6578 sync tokens), XML validation and auto-correction.
- **Risk:** 0 stars, single maintainer

### `emersion/go-webdav` — Generic CalDAV/CardDAV Library

- **URL:** https://github.com/emersion/go-webdav
- **Stars:** 458 | **Last active:** 2025-12
- **VTODO:** Yes (generic `CompFilter` supports any component type)
- **iCloud tested:** Not specifically, but implements RFC 4791
- **Dependencies:** `emersion/go-ical`, `emersion/go-vcard`
- **Notable:** Ecosystem standard. Both client and server. PROPFIND, REPORT, CalendarQuery. Would need iCloud-specific auth + discovery layer on top.

### `tarekbecker/icloud-reminders-cli` — CloudKit API (Non-CalDAV)

- **URL:** https://github.com/tarekbecker/icloud-reminders-cli
- **Stars:** 1 | **Last active:** 2026-02-27
- **VTODO:** N/A (uses CloudKit, not CalDAV)
- **iCloud tested:** Yes — native CloudKit API with full 2FA support
- **Notable:** List/add/complete/delete reminders, hierarchical subtasks, batch operations, list management, session caching. This is the alternative if CalDAV VTODO is dead.
- **Risk:** Undocumented private Apple API

### `tomoconnor/gocalsync` — CalDAV Sync (Events Only)

- **URL:** https://github.com/tomoconnor/gocalsync
- **Stars:** 2 | **Last active:** 2026-01
- **VTODO:** No (VEVENT only)
- **iCloud tested:** Yes — bidirectional iCloud <-> Google Calendar sync
- **Notable:** Proves iCloud CalDAV auth/discovery works in Go. Good reference for the PROPFIND chain.

### `cyp0633/libcaldora` — WIP CalDAV Client/Server

- **URL:** https://github.com/cyp0633/libcaldora
- **Stars:** 1 | **Last active:** 2026-02
- **VTODO:** Unknown (WIP)
- **Notable:** Builds on `emersion/go-ical`. Auto-discovery via DNS SRV + `.well-known`. Too early to depend on.

## Python Projects (Proof That CalDAV VTODO + iCloud Works)

### `pimutils/vdirsyncer` — CalDAV/CardDAV Sync

- **URL:** https://github.com/pimutils/vdirsyncer
- **Stars:** 1,783 | **Last active:** 2026-02
- **VTODO:** Yes | **iCloud tested:** Yes
- **Notable:** The most battle-tested iCloud CalDAV sync tool in any language. Primary evidence that CalDAV VTODO works with iCloud.

### `pimutils/todoman` — VTODO Task Manager

- **URL:** https://github.com/pimutils/todoman
- **Stars:** 569 | **Last active:** 2026-02
- **VTODO:** Yes | **iCloud tested:** Yes (via vdirsyncer)
- **Notable:** CLI task manager consuming VTODO files. Proves the VTODO format is usable for task management.

### `python-caldav/caldav` — Python CalDAV Library

- **URL:** https://github.com/python-caldav/caldav
- **Stars:** 394 | **Last active:** 2026-03
- **VTODO:** Yes | **iCloud tested:** Partially — maintainers documented "no support for tasks" on iCloud as of 2021
- **Notable:** The iCloud VTODO incompatibility was documented here. But the library is still actively maintained for other CalDAV servers.

### `keithvassallomt/icloudbridge` — Apple Reminders to CalDAV Bridge

- **URL:** https://github.com/keithvassallomt/icloudbridge
- **Stars:** 94 | **Last active:** 2026-02
- **Notable:** Syncs Apple Reminders TO CalDAV VTODO (e.g., Nextcloud Tasks). This likely uses EventKit or private APIs to READ reminders from Apple, then WRITES them as VTODO to another server. Does NOT necessarily prove reading VTODO from iCloud CalDAV works.

## TypeScript Projects

### `natelindev/tsdav` — WebDAV/CalDAV/CardDAV Client

- **URL:** https://github.com/natelindev/tsdav
- **Stars:** 332 | **Last active:** 2026-02
- **VTODO:** Yes | **iCloud tested:** Yes (documented)

## Utility Projects

### `muhlba91/icloud-caldav-urls` — iCloud CalDAV URL Discovery

- **URL:** https://github.com/muhlba91/icloud-caldav-urls
- **Stars:** 130 | **Last active:** 2025-04
- **Notable:** Groovy utility to discover iCloud CalDAV/CardDAV URLs. Documents the endpoint discovery process.
