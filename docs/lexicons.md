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

## Publication Icon

`publication.icon` is an OPTIONAL blob. Omitted means the publishing
implementation's own mark, which is what every publication showed before the
field existed — so adding it changes nothing for records that do not carry one.

- Accepted types: `image/png`, `image/jpeg`. Maximum 500,000 bytes.
- Clients SHOULD upload a square image of at least 256×256, because every
  delivery size is derived by downscaling and there is no way to invent detail
  that was not uploaded.
- The blob is the **source image, not a delivery artifact**. An implementation
  resizes and re-encodes it for what its delivery needs — a favicon at several
  sizes, a feed image, a touch icon — and MUST NOT assume the stored bytes are
  directly servable at any particular size. Implementations MUST NOT require a
  particular aspect ratio; a non-square image is fitted, not rejected.
- The icon is presentation, like the name and the slug. Item identity never
  depends on it, and replacing it MUST NOT re-deliver feed items.

A note for implementers, because the feature is easy to over-promise: search
engines generally show one favicon per **hostname**, taken from that host's home
page. A publication served from a shared host therefore reaches browser tabs,
feed readers, and share cards with its own icon, but not search results. Search
results follow only when a publication has a host of its own.

## Size Limits And Rationale

| Field | Limit | Rationale |
|---|---|---|
| `article.content` | 100,000 bytes | Interoperable with existing AT Protocol long-form writing (WhiteWind uses the same bound); comfortably fits long technical articles while bounding record size |
| `article.title` | 300 graphemes / 3,000 bytes | Grapheme limit is the user-facing bound; the 10× byte limit keeps multi-byte scripts (Korean, emoji) from hitting byte limits first |
| `article.summary`, `publication.description` | 600 graphemes / 6,000 bytes | Same pattern |
| `publication.name` | 100 graphemes / 1,000 bytes | Same pattern |
| slugs | 60 bytes | ASCII-only, so bytes = characters |
| `publication.icon` | 500,000 bytes | An icon is delivered at a few hundred pixels square; this leaves room for a lossless source at 1024×1024 without inviting a photograph |

Limits only ever grow (see `versioning.md`).

## Dates

All timestamps are RFC 3339 (`format: datetime`) and client-declared.
Services SHOULD treat implausible timestamps (far future) with care when
ordering feeds but MUST NOT reject otherwise valid records because of
ordering concerns. `publishedAt` drives feed ordering; `updatedAt`, when
present, drives update signaling in feeds.

## Markdown Dialect

`article.content` is Markdown: CommonMark plus the GFM tables and
strikethrough extensions, footnotes, and a table-of-contents marker. Raw HTML
blocks in Markdown MUST be treated as untrusted input by renderers (escaped or
sanitized, never emitted verbatim into feeds or pages without sanitization).
Rendering requirements for feeds live in `rss-atom-mapping.md`.

### Footnotes

A reference is `[^label]` and its definition is `[^label]: content`, as in
Pandoc and PHP Markdown Extra. Labels are identifiers only, never presentation:
a renderer MUST number footnotes by order of first reference and MUST NOT emit
the label. A reference with no matching definition is not a footnote and SHOULD
be left as the author wrote it.

Numbering rather than labelling is a requirement, not a stylistic preference. A
label is arbitrary author text on a path to an `id` and an `href`, and numbering
removes that path rather than sanitizing it.

### Table Of Contents

A block consisting only of `[TOC]`, matched ASCII-case-insensitively and
ignoring surrounding whitespace, is replaced by a nested list of links to the
document's headings, in document order and nested by heading level. The marker
has no meaning inside a code span or fence, or within a larger paragraph. A
document with no headings renders no list, and the marker MUST NOT survive into
the output.

This is an `app.nooker` extension rather than CommonMark, and a client offering
it should say so.

### Heading Anchors

A renderer MUST give every heading a fragment identifier derived from the
heading's text content:

1. Fold diacritics over Latin letters only — `Café` becomes `cafe`. A mark over
   another script is part of the letter and MUST be kept: Japanese `じ`
   decomposes to `し` plus a dakuten, and folding that changes the word.
2. Keep letters and digits, lowercased; replace every other character with a
   hyphen.
3. Collapse runs of hyphens and trim them from both ends.
4. A heading with nothing left is `section`.
5. Repeats leave the first unsuffixed and number the rest from `-2`.

Letters, not ASCII. A scheme restricted to ASCII gives every heading in Korean,
Japanese, or Chinese the same empty anchor, which makes a table of contents
useless in the languages this contract is most used in.

The resulting alphabet — letters, digits, and hyphen — is what makes an anchor
safe to place in an `id` or an `href` without further escaping.

## Missing References And Orphans

An article whose `publication` AT URI does not resolve to an existing
`app.nooker.publication` record is an orphan: schema-valid, but excluded
from rendered pages and feeds (`deletion.md` covers the deletion-driven
case). Fixtures cover this scenario.
