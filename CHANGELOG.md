# Changelog

Repository releases are semantic version tags describing the repository and
its generated artifacts; see `docs/versioning.md`.

## v0.2.2 — 2026-07-30

No Lexicon changes.

Added:

- `reason` on problem documents: a small closed vocabulary naming the cause
  a user has to act on, for the cases where `type` is too coarse to say what
  to change. A client translates it; `detail` stays English prose for logs.
  Additive in both directions — a service may omit it, and a client MUST read
  an unrecognised value as absent and fall back to `type`.
- `ProblemReason` in the Swift package, with `offendingField` so a form knows
  where to put the focus.

## v0.2.1 — 2026-07-29

No Lexicon changes.

Added:

- `handleResolves` on the signup response, so a client can distinguish an
  account whose handle has not propagated yet from a failure.

## v0.2.0 — 2026-07-29

No Lexicon changes: NSIDs, fields, and constraints are untouched, so every
record valid under v0.1.0 remains valid.

Added:

- `PUT` and `DELETE` for publications. Deleting a publication does not
  cascade to its articles.
- Record CIDs on publication and article responses, returned as a strong
  `ETag` and accepted back as `If-Match` for compare-and-swap mutation.
  A stale CID yields `412 record-conflict` with no write.
- A permanent record-key alias for article URLs, redirecting to the
  canonical slug URL, so a link cannot break when a slug changes outside
  the service.
- `POST`/`GET /v1/service-disconnection-requests`, with
  `/v1/account/deletion-requests` retained as a deprecated alias.
- `docs/client-data-flow.md`: reads come from the PDS, the service API is a
  mutation fast path, and direct PDS mutation is legitimate.
- `docs/account-lifecycle.md`: content deletion, service disconnection, and
  PDS account deletion are three distinct operations.
- `docs/lexicon-publishing.md` and a `lex-published` check for network
  schema resolution.
- Stable problem types, declared as protocol constants, including the new
  `invalid-request` and `invalid-session`.
- `NookPlusServiceAPI`: service API types and client generated from the
  OpenAPI document at build time.
- `ATRecord` and `ATRecordPage` envelopes for decoding PDS record responses.

Changed:

- `swift-tools-version` raised to 6.1.
- The hand-written Swift service API types are deprecated; they are removed
  in v1.0.0.

## v0.1.0 — 2026-07-28

Initial protocol surface:

- `app.nooker.publication` and `app.nooker.article` Lexicons (tid record
  keys, AT-URI publication references, publish-by-presence semantics).
- Normative documentation: ownership, deletion semantics and limits, data
  portability and rebuild principles, versioning and compatibility policy,
  Lexicon design notes, RSS/Atom mapping rules, HTTP API conventions, and
  unresolved decisions.
- Canonical record fixtures (valid and invalid) covering Korean text,
  emoji, XML special characters, Markdown features, optional-field
  omission, boundary lengths, and orphaned publication references.
- RSS 2.0 and Atom 1.0 conformance fixtures for nine mutation scenarios,
  validated for well-formedness, against the vendored RFC 4287 RelaxNG
  schema, with a real feed parser, and with item-identity stability tests.
- Public HTTP API contract (OpenAPI 3.1) for invitations, signup,
  membership, publishing, export, and account deletion.
- Public Go types (`generated/go`) and a Swift package
  (`NookPlusProtocol`), both locked to the shared fixtures by round-trip
  conformance tests.
- `make verify` validation pipeline and GitHub Actions CI.
