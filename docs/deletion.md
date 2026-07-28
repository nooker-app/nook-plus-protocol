# Deletion Semantics And Limits

The key words MUST, SHOULD, and MAY are used as defined in RFC 2119.

## The Source Record Is The Deletion Authority

Deleting an `app.nooker.article` or `app.nooker.publication` record from the
user's PDS repository is the authoritative deletion signal. A conforming
service determines deletion by the absence of the record in the repository,
not by any secondary flag or event payload.

## Propagation

Services MAY process deletions asynchronously, but MUST remove the deleted
content from every representation under their control within a documented
propagation delay. The reference propagation delay for this protocol is
**2 minutes under normal operation**, covering at least:

- The article's rendered HTML page
- The publication index page
- RSS and Atom feeds
- Stored derived objects
- Service-controlled caches and CDN responses
- Public listing or search indexes operated by the service

A missed or failed deletion event MUST eventually converge to the same result,
for example through periodic reconciliation against the current repository
state.

Retries, replayed events, stale task payloads, and reconciliation runs MUST
NOT recreate content whose source record no longer exists.

## Publication Deletion And Orphaned Articles

Deleting a publication record does not delete its article records; a service
has no authority to delete other records from a user's repository.

An article whose referenced publication record does not exist (or no longer
exists) remains schema-valid, but conforming services MUST exclude it from
rendered pages and feeds until it references an existing publication.

## Users Retain Deletion Access

A service MUST NOT block a user's ability to delete their own records or to
export them, regardless of the user's service-membership status.

## Limits

Deletion applies to representations the service controls. Copies already
fetched or stored by third parties — feed readers, search engines, archives,
other AT Protocol consumers — are outside any service's control. Conforming
implementations MUST NOT claim that deletion retracts such copies.
