# Lexicon Design Notes

This document records the design decisions behind the `app.nooker` Lexicons
and the constraints that interoperability depends on. The key words MUST,
SHOULD, and MAY are used as defined in RFC 2119.

## Record Keys And References

- Both record types use `tid` record keys. The AT URI
  (`at://{did}/{collection}/{rkey}`) is the permanent identity of a record.
- Slugs are **not** record keys. Slugs are mutable presentation attributes;
  putting them in the rkey would make them immutable and leak presentation
  concerns into identity.
- An article references its publication by AT URI (`format: at-uri`), not by
  a `com.atproto.repo.strongRef`. A strongRef pins a specific CID, which
  would go stale every time the publication record is edited; the reference
  here is to the publication as a living record, not to one revision of it.

## Publish-By-Presence

Presence of a record in the user's repository is what makes it public. There
is no draft flag and no visibility field in this revision:

- Drafts live in clients, outside the protocol.
- Implementations MUST treat every `app.nooker.article` record as published.
- A future revision MAY add visibility semantics as an OPTIONAL field;
  omitting the field will keep today's meaning, so the extension is additive.

## Publications Per Repository

A repository MAY contain any number of publication records. Services MAY
choose to provision a default publication per account and MAY limit how many
a user can create, but the schema does not constrain the count.

## Slug Rules

- Allowed characters: lowercase ASCII letters `a-z`, digits `0-9`, hyphen
  `-`. A slug MUST NOT start or end with a hyphen. (The Lexicon language has
  no pattern constraint, so this rule is normative prose; conforming
  implementations MUST enforce it.)
- Length: 1–60 characters.
- Slugs are mutable. Feed item identity MUST NOT depend on them
  (see `rss-atom-mapping.md`).
- Uniqueness is a service concern: publication slugs are unique within one
  publishing service's public URL space, and article slugs are unique within
  a publication as served by that service. A decentralized schema cannot
  enforce global uniqueness, so this schema only constrains form and length.

## Size Limits And Rationale

| Field | Limit | Rationale |
|---|---|---|
| `article.content` | 100,000 bytes | Interoperable with existing AT Protocol long-form writing (WhiteWind uses the same bound); comfortably fits long technical articles while bounding record size |
| `article.title` | 300 graphemes / 3,000 bytes | Grapheme limit is the user-facing bound; the 10× byte limit keeps multi-byte scripts (Korean, emoji) from hitting byte limits first |
| `article.summary`, `publication.description` | 600 graphemes / 6,000 bytes | Same pattern |
| `publication.name` | 100 graphemes / 1,000 bytes | Same pattern |
| slugs | 60 bytes | ASCII-only, so bytes = characters |

Limits only ever grow (see `versioning.md`).

## Dates

All timestamps are RFC 3339 (`format: datetime`) and client-declared.
Services SHOULD treat implausible timestamps (far future) with care when
ordering feeds but MUST NOT reject otherwise valid records because of
ordering concerns. `publishedAt` drives feed ordering; `updatedAt`, when
present, drives update signaling in feeds.

## Markdown Dialect

`article.content` is Markdown: CommonMark plus the GFM tables and
strikethrough extensions. Raw HTML blocks in Markdown MUST be treated as
untrusted input by renderers (escaped or sanitized, never emitted verbatim
into feeds or pages without sanitization). Rendering requirements for feeds
live in `rss-atom-mapping.md`.

## Missing References And Orphans

An article whose `publication` AT URI does not resolve to an existing
`app.nooker.publication` record is an orphan: schema-valid, but excluded
from rendered pages and feeds (`deletion.md` covers the deletion-driven
case). Fixtures cover this scenario.
