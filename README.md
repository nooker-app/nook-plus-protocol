# Nook Plus Protocol

This repository defines the public interoperability contract for publishing
Nook publications and articles through the [AT Protocol](https://atproto.com)
and standard syndication formats (RSS 2.0 and Atom 1.0).

It is written for independent implementers. Everything needed to produce or
consume conforming records, feeds, and API requests is contained in this
repository; no access to any particular service implementation is required.

## What This Repository Contains

| Directory | Contents |
|---|---|
| `lexicons/` | AT Protocol Lexicons for the `app.nooker` namespace |
| `fixtures/valid/` | Canonical record examples that MUST validate |
| `fixtures/invalid/` | Record examples that MUST be rejected |
| `fixtures/rss/`, `fixtures/atom/` | Expected RSS 2.0 / Atom 1.0 feed output for defined scenarios |
| `openapi/` | Public HTTP API contract (OpenAPI) |
| `generated/go/`, `generated/swift/` | Public Go and Swift types |
| `docs/` | Normative documentation: ownership, deletion, portability, versioning, feed mapping |
| `schemas/` | Vendored XML schemas used to validate feed fixtures |
| `scripts/` | Local validation helpers |

## Core Principles

- **User content is user-owned.** A user's publications and articles are
  authoritative as AT Protocol records in the user's own PDS repository.
  Rendered HTML, RSS, Atom, indexes, and caches are derived data.
- **Identity is the DID.** Handles, slugs, display names, and domains are
  mutable presentation attributes. Feed item identity is anchored to AT URIs,
  never to presentation URLs.
- **Deletion of the source record is the deletion authority.** Conforming
  services remove derived representations within a documented propagation
  delay. No implementation can retract copies already fetched by third
  parties, and none should claim to.
- **Derived data is rebuildable.** A conforming service can be reconstructed
  from authoritative records plus minimal service metadata.
- **Version 1 content is Markdown text.** There are no image, media, or
  attachment semantics in this revision.

See `docs/ownership.md`, `docs/deletion.md`, `docs/portability.md`, and
`docs/versioning.md` for the normative details.

## Record Types

- `app.nooker.publication` — a publication (a named feed of articles).
- `app.nooker.article` — a Markdown article belonging to a publication,
  referenced by a stable AT URI.

## Validation

From a clean checkout (Go 1.24+, `xmllint`, and Node.js for the OpenAPI
linter; run `make install-tools` once for the Lexicon CLI):

```sh
make verify      # lex-lint, lex-breaking, fixtures-test, xml-validate,
                 # openapi-lint, generate-check
make swift-test  # Swift package tests (requires a Swift 6 toolchain)
```

Individual targets are documented in the `Makefile`. CI runs both on every
push.

## Using The Types

- **Go**: `go get github.com/nooker-app/nook-plus-protocol` — record types
  in `generated/go/nookplusrecords`, API model types in
  `generated/go/nookplusapi`.
- **Swift**: add this repository as a Swift Package Manager dependency and
  import `NookPlusProtocol`. All types are `Codable` and `Sendable`.

## Versioning

Lexicon NSIDs are permanent and evolve additively; breaking changes require a
new NSID or definition name. Repository releases are tagged with semantic
versions that describe the repository and its generated artifacts, not the
Lexicons themselves. See `docs/versioning.md`.

## Examples And Fixtures

All examples use reserved example domains (`example.com` and subdomains) and
obviously synthetic DIDs, handles, and content. They never reference real
users or deployments.

## License

MIT — see `LICENSE`.
