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
   membership state, publishing operations, export, and disconnection. It
   exists because account provisioning and hosted rendering are service
   functions, not protocol functions.

This API is a **mutation fast path, not a read API**. Clients read
authoritative content straight from the PDS; see `client-data-flow.md` for
the full split and `account-lifecycle.md` for how the three kinds of
deletion differ.

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

## Conditional mutation with CIDs

Publication and article responses carry the record's `cid`, and mutations
return it in an `ETag` header as a strong entity tag:

```text
ETag: "bafyreiexamplecid"
```

Clients send the last CID they read back on a mutation:

```text
If-Match: "bafyreiexamplecid"
```

The server strips the quotes and forwards the CID to the PDS as a
compare-and-swap, so the write is rejected if the record changed in the
meantime. This exposes AT Protocol's `swapRecord` semantics directly rather
than inventing a parallel versioning scheme.

Rules:

- A quoted CID that no longer matches → `412` with `record-conflict`, and no
  mutation occurs.
- A malformed or unquoted `If-Match` → `400` with `invalid-request`. The
  header is wrong, not the record.
- `DELETE` of a record that is already gone → `204`, whether or not
  `If-Match` was sent.
- No `If-Match` → the mutation is unconditional. Clients that skip it accept
  the risk of overwriting a concurrent change.

Clients SHOULD always send it for updates and deletes, and MUST have a path
for `412` — re-read, reconcile, retry. Falling back to an unconditional
overwrite defeats the purpose of sending it.

**What the ETag identifies.** It carries the record's CID, not a hash of the
response body. Two responses with the same ETag describe the same record
revision but may differ if this API's response shape gains fields. Clients
MUST treat it as an opaque record version, and MUST NOT use it for HTTP
response caching.

## Errors

Errors are RFC 7807 `application/problem+json` documents. `detail` is
human-readable and unstable; never match on it. Error documents MUST NOT
contain passwords, tokens, invitation codes, emails, or article content.

### Problem types are protocol constants

The `type` values below are fixed identifiers. **Every conforming
implementation emits these exact strings, regardless of the domain it is
deployed on**, and clients match on them verbatim. They are not required to
be dereferenceable, and a client MUST NOT fetch them to decide anything.

This is why they differ from `servers` in the OpenAPI document, which is a
per-deployment placeholder: the server URL varies by deployment, the problem
type does not.

| `type` suffix under `https://nooker.app/problems/` | Status | Occurs on | User can fix | Safe to retry unchanged |
|---|---|---|---|---|
| `invalid-invitation` | 400 | invitation verify, signup | Yes — supply a valid code | No |
| `handle-unavailable` | 409 | handle availability, signup | Yes — choose another | No |
| `slug-unavailable` | 409 | publication create/update | Yes — choose another | No |
| `member-suspended` | 403 | publishing mutations | No — contact the operator | No |
| `member-revoked` | 403 | publishing mutations | No | No |
| `record-not-found` | 404 | article/publication read, update | No | No |
| `record-conflict` | 412 | conditional mutations | Yes — re-read and retry | No, re-read first |
| `invalid-record` | 400 | create, update | Yes — fix the fields | No |
| `invalid-request` | 400 | any | Yes — fix the request | No |
| `invalid-session` | 401 | any authenticated call | Yes — refresh or log in | After refreshing |
| `idempotency-conflict` | 409 | requests taking `Idempotency-Key` | Yes — use a new key | No |
| `rate-limited` | 429 | any | No — wait | Yes, after `Retry-After` |
| `pds-unavailable` | 502 | anything touching the PDS | No | Yes |

### `reason` names the cause a user has to act on

`type` says which class of thing went wrong; it is often not specific enough to
tell the user what to change. `invalid-request` covers a rejected email and a
rejected password alike, and a client that shows `detail` instead is showing
English prose written for whoever reads the log.

So a problem document MAY carry a `reason`: a machine-readable cause a client
translates into its own words. Clients MUST treat an unrecognised value as
absent and fall back to `type`, because values are added additively.

| `reason` | Usual `type` | Means |
|---|---|---|
| `email-already-used` | `invalid-request` | Another account already uses that email address |
| `email-invalid` | `invalid-request` | The repository host rejected the address itself |
| `password-too-weak` | `invalid-request` | The repository host requires a stronger password |
| `handle-taken` | `handle-unavailable` | Someone already holds that handle |
| `handle-invalid` | `invalid-request` | The name is not a usable handle label |
| `invitation-not-found` | `invalid-invitation` | No such invitation |
| `invitation-expired` | `invalid-invitation` | The invitation is past its expiry |
| `invitation-exhausted` | `invalid-invitation` | The invitation has no uses left |
| `account-password-mismatch` | `invalid-session` | The account already exists and this password does not open it |
| `repository-host-rejected` | `invalid-request` | The host refused for a reason the service could not classify |

`account-password-mismatch` is reachable on signup, not only on sign-in: a
resumed signup trades the password for a session, so a retry carrying a
different password than the attempt that created the account lands here. A
client should offer signing in rather than another attempt at signing up.

`Retry-After` is sent with `rate-limited` and MAY be sent with
`pds-unavailable`. It is a delay in seconds.

`idempotency-conflict` means the key was already used for a request whose
parameters differ. Reusing a key with identical parameters is a retry and
succeeds.

Rate limits are not yet specified beyond the type existing: a service MUST
send `Retry-After` when it returns `rate-limited`, and a future revision
will document concrete limits.

## Asynchronous Publishing

Record mutations return once the authoritative record is written. Public
representations (HTML, RSS, Atom) update asynchronously; `deletion.md`
documents the propagation bound. Clients SHOULD NOT poll public URLs to
confirm a write succeeded.

## Compatibility

The API is versioned in the URL path (`/v1`). Within a version, evolution
is additive; see `versioning.md`. Clients MUST ignore unknown response
fields.
