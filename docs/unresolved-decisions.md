# Unresolved Decisions

Items that affect public interoperability but are intentionally not decided
in the current revision. Nothing here is stable; see `versioning.md`.

## Authentication Evolution

The initial HTTP API contract authenticates with a PDS session access token
as a Bearer credential. Whether and when to move to AT Protocol OAuth is
undecided. A change here would be a breaking API-contract change and would
follow the versioning policy.

## Slug-Change URL Behavior

Slugs are mutable and feed identity is AT-URI-based, so a slug change is safe
for feeds. Whether services redirect old presentation URLs after a slug
change (and for how long) is a service-quality concern, not yet a protocol
requirement. A future revision MAY add a SHOULD-level recommendation.

## Visibility Semantics

This revision is publish-by-presence with no visibility field. If a future
revision adds one (for example unlisted articles), it must be an OPTIONAL
field whose absence preserves today's meaning.

## Lexicon Resolution Publishing

Publishing the `app.nooker` Lexicons for network resolution
(`com.atproto.lexicon.schema` records plus `_lexicon` DNS TXT) is planned but
not yet done. Until then, this repository is the authoritative source of the
schemas.

## Cross-Posting

Automatic cross-posting of articles to other AT Protocol applications (for
example microblogging apps) is out of scope for this revision and has no
schema support.

## Media

Image and media semantics are explicitly excluded from this revision
(`ownership.md`). Adding them would be a significant protocol revision, not
an additive tweak.
