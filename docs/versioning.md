# Versioning And Compatibility Policy

The key words MUST, SHOULD, and MAY are used as defined in RFC 2119.

## Lexicon Evolution

Lexicon NSIDs (`app.nooker.publication`, `app.nooker.article`) are permanent.
Published Lexicons evolve additively:

- New OPTIONAL fields MAY be added.
- Published fields MUST NOT be removed or renamed.
- Constraints MUST NOT become stricter for data that was previously valid
  (for example, a maximum length MUST NOT decrease and a formerly optional
  field MUST NOT become required).
- Semantics of an existing field MUST NOT change incompatibly.

The compatibility contract is bidirectional: records written under an older
schema revision MUST validate against the newer schema, and records written
under the newer schema MUST validate against the older one (unknown fields
are ignored per AT Protocol data-model rules).

A change that cannot satisfy these rules is a breaking change and MUST be
introduced under a new NSID or a new definition name within the schema,
together with a documented migration path. Old NSIDs remain valid for
already-written records.

## Repository Releases

This repository is released with semantic version tags (for example,
`v0.1.0`). A tag versions the repository as a whole — documentation,
fixtures, the HTTP API contract, and generated types — **not** the Lexicons,
which have no version numbers of their own.

- MAJOR: breaking change to the HTTP API contract or generated types.
- MINOR: additive schema fields, new endpoints, new fixtures or documents.
- PATCH: clarifications and fixes that change no contract semantics.

Before `v1.0.0`, MINOR releases MAY contain breaking changes to the HTTP API
contract (but never to published Lexicon records); each such change is noted
in the changelog.

## HTTP API Contract

The public HTTP API is versioned in its URL path (`/v1/...`). Within a path
version, changes MUST be backward compatible for clients: fields are added,
never removed or repurposed. Unknown response fields MUST be ignored by
clients.

## Stability Labels

Nothing in this repository is stable until it appears in a tagged release.
Documentation MUST NOT describe unreleased fields or behavior as stable.

## Fixtures Are Part Of The Contract

Conformance fixtures are updated in the same change as the schema or mapping
rule they exercise. A release tag always contains mutually consistent
Lexicons, documentation, fixtures, and generated types.
