# Content Ownership

This document defines which data is authoritative, which is derived, and which
is presentation-only. The key words MUST, SHOULD, and MAY are used as defined
in RFC 2119.

## Authoritative Data

The authoritative source for user-authored content is the set of AT Protocol
records in the user's own PDS repository:

- `app.nooker.publication` records
- `app.nooker.article` records

The record's AT URI (`at://{did}/{collection}/{rkey}`) is its permanent
identity. The DID identifies the owner. Ownership is a property of the
repository the record lives in, never of any service database row.

An article record present in a user's PDS repository is public. This protocol
revision has no draft or visibility state: unpublished drafts are out of scope
and MUST NOT be represented as `app.nooker.article` records. A future revision
MAY add visibility semantics additively.

## Derived Data

Everything a service produces from authoritative records is derived and MUST
be rebuildable from authoritative records plus minimal service metadata:

- Rendered article and publication HTML
- RSS 2.0 and Atom 1.0 feeds
- Search or listing indexes
- Caches and CDN responses

A conforming service MUST be able to regenerate all derived representations
given only: the users' PDS records, its own minimal operational metadata
(membership, handle, and slug assignments), configuration, and source code.

## Presentation-Only Attributes

The following attributes affect how content is displayed or addressed, but
MUST NOT be used as identity:

- Handles (mutable labels resolved from the DID)
- Publication and article slugs (mutable URL path segments)
- Display names and publication names
- Base domains and custom domains

When any of these change, record identity — the AT URI — is unchanged, and
derived representations MUST keep stable item identity (see
`rss-atom-mapping.md`).

## Prohibited Content In Records

Public records MUST NOT contain:

- Service-private database identifiers or storage paths
- Environment-specific hostnames or API base URLs
- Queue names, task identifiers, or other operational state

Records MUST remain portable between conforming PDS hosts and conforming
service implementations.
