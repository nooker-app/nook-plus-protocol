# Public HTTP API

The machine-readable contract is `openapi/openapi.yaml` (OpenAPI 3.1). This
page explains its scope and the conventions the schema cannot express. The
key words MUST, SHOULD, and MAY are used as defined in RFC 2119.

## Two Contracts, Clearly Separated

This repository defines two different things:

1. **The interoperability contract** — the `app.nooker` Lexicons, the
   ownership/deletion semantics, and the RSS/Atom mapping. Any independent
   implementation that reads records from a PDS can produce conforming
   pages and feeds using only that contract. It does not involve this API.
2. **The service API** (this document) — the HTTP surface a client uses to
   operate a Nook Plus publishing service: invitation checks, signup,
   membership state, publishing operations, export, and deletion. It exists
   because account provisioning and hosted rendering are service functions,
   not protocol functions.

## Authentication

Requests to member endpoints carry the member's PDS session access token:

```text
Authorization: Bearer {accessJwt}
```

The server validates the token against its PDS and derives the member DID
from it. Passwords appear in exactly one request (signup) and are forwarded
only to the PDS account-creation boundary; servers MUST NOT store or log
them. A move to AT Protocol OAuth is an open item in
`unresolved-decisions.md`.

## Identity Conventions

- The member identifier in all service data is the DID.
- Records are addressed by rkey within the authenticated member's own
  repository; the API never operates on another member's records.
- Responses reference records by AT URI. Internal database identifiers,
  storage paths, or other implementation details MUST NOT appear in this
  API.

## Idempotency

Mutating endpoints marked with the `Idempotency-Key` header parameter
require a client-generated opaque key. Servers MUST ensure a retried
request with the same key does not repeat side effects — in particular,
signup retries MUST NOT create a second account or DID, and article
creation retries MUST NOT create duplicate records. Servers SHOULD retain
keys for at least 24 hours.

Record deletion is naturally idempotent: deleting an absent record returns
success.

## Errors

Errors are RFC 7807 `application/problem+json` documents. The `title` and
`type` fields are stable identifiers for programmatic handling; `detail` is
human-readable and unstable. Error documents MUST NOT contain passwords,
tokens, invitation codes, emails, or article content.

## Asynchronous Publishing

Record mutations return once the authoritative record is written. Public
representations (HTML, RSS, Atom) update asynchronously; `deletion.md`
documents the propagation bound. Clients SHOULD NOT poll public URLs to
confirm a write succeeded.

## Compatibility

The API is versioned in the URL path (`/v1`). Within a version, evolution
is additive; see `versioning.md`. Clients MUST ignore unknown response
fields.
