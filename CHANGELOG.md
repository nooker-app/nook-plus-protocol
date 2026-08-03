# Changelog

Repository releases are semantic version tags describing the repository and
its generated artifacts; see `docs/versioning.md`.

## v0.3.1 — 2026-08-04

No contract semantics change. `PublicationInput.icon` and `Publication.icon` now
reference `BlobRef` directly instead of wrapping it in a single-member `allOf`,
which existed only to attach a description — OpenAPI 3.1 allows that beside a
`$ref`. The wrapper made the generated Swift type an extra layer for every client
to unwrap.

## v0.3.0 — 2026-08-03

Lexicon change, additive:

- **`app.nooker.publication.icon`.** An OPTIONAL blob (`image/png` or
  `image/jpeg`, at most 500,000 bytes) giving a publication its own icon, used as
  the favicon of its pages and as its feed image. Omitting it means the
  publishing implementation's own mark, which is what every publication showed
  before the field existed, so records written under the previous revision remain
  valid and unchanged in meaning.

  The blob is the source image rather than a delivery artifact: an implementation
  derives the sizes and formats its delivery needs, so a client uploads one square
  image and does not produce an `.ico`. See `docs/lexicons.md` for the rules and
  for the part worth knowing before the feature is offered to anyone — a search
  engine shows one favicon per hostname, so a per-publication icon reaches browser
  tabs, feed readers, and share cards, but not search results, until the
  publication has a host of its own.

- Feed mapping gains the icon: RSS `image` (`url`, `title`, `link`) and Atom
  `icon`/`logo`, falling back to the service's own mark.

HTTP API, additive:

- **`PublicationInput.icon` and `Publication.icon`/`iconUrl`.** A client uploads
  the image to its own repository with `com.atproto.repo.uploadBlob` and sends the
  reference; the bytes never pass through this API. Putting them through it would
  place user content in a second location for no gain and make the upload depend
  on the service being reachable.

  `PUT /v1/publications/{rkey}` replaces the record, so an omitted icon is
  removed — the rule `description` already follows. A client editing anything else
  must send the icon it wants kept.

  `iconUrl` is where the derived icon is served from. Absent until the first
  render after an upload, and absent for a publication using the service's mark.

Also in this release, and not a contract change:

- The conformance harness parses record fixtures through the AT Protocol data
  model instead of `encoding/json`. The two disagree about the types the model
  defines — a blob arrives as `{"$type":"blob", ...}` and the validator expects it
  to have become a blob rather than a plain map — so no fixture carrying one could
  have validated. Decoding fixtures the way the protocol decodes them is also
  closer to what they are for.

## v0.2.4 — 2026-07-31

No Lexicon changes.

Added to the Markdown dialect, which the composer already offers and so was
already in use before being written down here:

- **Footnotes.** `[^label]` and `[^label]: content`, as in Pandoc and PHP
  Markdown Extra. Labels are identifiers only: a renderer MUST number footnotes
  by order of first reference and MUST NOT emit the label. That is a security
  requirement rather than a stylistic one — a label is arbitrary author text on
  a path to an `id` and an `href`, and numbering removes the path instead of
  sanitizing it. An undefined reference is not a footnote.

- **`[TOC]`.** A block that is only the marker becomes a nested list of links to
  the document's headings. Case-insensitive, whitespace-tolerant, and inert
  inside a code span or fence or within a larger paragraph. No headings means no
  list, and the marker never reaches the output.

- **Heading anchors.** Specified, because both features link to them and because
  the obvious implementation is wrong for most of this contract's traffic:
  restricting anchors to ASCII gives every Korean, Japanese, or Chinese heading
  the same empty identifier. Diacritics fold over Latin letters only — folding
  every combining mark turns Japanese `じ` into `し`, a different word. The
  resulting alphabet of letters, digits, and hyphen is what makes an anchor safe
  in an attribute without further escaping.

Feed requirement:

- Identifiers generated inside a feed item MUST be namespaced per article. One
  feed document holds many articles, so an unqualified `fn:1` is claimed by every
  item that has a footnote. Links to them stay document-relative fragments.

## v0.2.3 — 2026-07-30

No Lexicon changes.

Relaxed:

- `If-Match` now accepts three spellings of the same CID: the quoted entity tag
  (`"bafyrei…"`), the bare CID (`bafyrei…`), and the quoted form with its quotes
  percent-encoded (`%22bafyrei…%22`). A server MUST accept all three and treat
  them as the same value.

  The third is not hypothetical. Header values are commonly serialized by
  generated clients as URI components, which percent-encodes `"`; a client
  feeding an `ETag` back therefore sends `%22…%22` and has no way not to. The
  previous wording required the quoted form and rejected everything else, which
  left a conforming generated client unable to delete a record at all.

  This is a relaxation, so every client that satisfied the old rule satisfies
  this one. An empty entity tag (`""`) is still rejected: it names no CID, and
  accepting it would quietly turn a conditional mutation into an unconditional
  one.

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
