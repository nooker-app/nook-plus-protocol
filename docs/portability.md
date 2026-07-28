# Data Portability And Rebuild Principles

The key words MUST, SHOULD, and MAY are used as defined in RFC 2119.

## Rebuild Guarantee

A conforming publishing service MUST be reconstructible — on different
infrastructure, a different provider, or a fresh environment — from exactly
these inputs:

1. The users' authoritative PDS records (`app.nooker.*`)
2. A backup of the service's minimal operational metadata
   (membership status, handle assignments, slug assignments)
3. Configuration
4. Source code

All rendered HTML, feeds, and indexes are derived data and MUST be
regenerable from the inputs above. Derived artifacts MUST NOT be the only
copy of any user-authored content.

This guarantee is why public records MUST NOT embed provider-specific
identifiers (database IDs, storage paths, queue names, environment hostnames):
any such value would tie the authoritative data to one deployment.

## Export

Users MUST be able to export their authoritative records. The AT Protocol
already provides repository export (for example, a CAR file via
`com.atproto.sync.getRepo`); a conforming service MUST NOT obstruct it and
SHOULD additionally offer a service-level export of the user's
`app.nooker.*` records in a documented format.

Export covers authoritative records. Client-local drafts are not part of the
protocol and are therefore outside export scope.

## Identity Survives Migration

- The DID is the stable owner identifier across any migration.
- Records MUST remain valid when hosted on a different conforming PDS.
- Presentation URLs MAY change when a service, base domain, or custom domain
  changes; feed item identity MUST NOT (see `rss-atom-mapping.md`).
- A custom presentation domain MUST NOT alter the DID, the handle, or record
  ownership.

## Documentation Requirements For Implementations

Implementations SHOULD document, without assuming a single hosting provider:

- Which operational metadata they consider minimal and back up
- Their rebuild procedure from the four inputs above
- Their export formats and how users invoke them
