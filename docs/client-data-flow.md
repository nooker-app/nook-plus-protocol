# Client Data Flow

Which system a client talks to for which operation, and why the split falls
where it does. The key words MUST, SHOULD, and MAY are used as defined in
RFC 2119.

The short version: **reads go to the PDS, mutations may go through either,
and the service owns only what a PDS cannot do.**

## Read directly from the PDS

A client MUST read authoritative content from the owner's PDS rather than
from a service API:

| Operation | Method |
|---|---|
| Log in, refresh a session | `com.atproto.server.createSession`, `refreshSession` |
| List publications or articles | `com.atproto.repo.listRecords` |
| Read one record, with its CID | `com.atproto.repo.getRecord` |
| Export the whole repository | `com.atproto.sync.getRepo` |
| Manage the hosted account | `com.atproto.server.*` |

`listRecords` and `getRecord` already return the URI, the CID, and the
record value, so this protocol deliberately defines **no article read
API**. Adding one would create a second source for data the PDS already
serves authoritatively, and the two could disagree.

Clients decode these responses into `PublicationRecord` and `ArticleRecord`
using the generic record envelopes (`ATRecord`, `ATRecordPage` in the Swift
package) rather than service-specific wrappers.

## Use the service API for what a PDS cannot do

| Operation | Why the service |
|---|---|
| Verify an invitation, sign up | Account provisioning needs the PDS admin boundary |
| Check handle and slug availability | Uniqueness is service-scoped; a PDS cannot see it |
| Read membership state | Membership is service data |
| Create, update, delete publications and articles | Fast path: one call writes the record and schedules rendering |
| Look up a publication's public URLs | The URL scheme is a service concern |
| Service-level export | Convenience alongside the PDS's own export |
| Disconnect from the service | Removes service-held data |
| **Handle resolution records** | The service owns the handle namespace and publishes what makes a handle resolve |

A successful service mutation MUST mean the authoritative PDS record was
written. The service never reports success for a record it failed to write.

## Direct PDS mutation is legitimate

A user MAY change their own records through the PDS directly, bypassing the
service entirely. This is not an error state and implementations MUST NOT
treat it as one.

The consequence is that a service cannot rely on being told about changes.
When a mutation arrives through the service, it schedules rendering
immediately. When it does not, reconciliation MUST converge the public
representations — HTML, feeds, caches — on the current PDS state within the
propagation delay documented in `deletion.md`.

This is why the service's fast path is an optimisation, not the source of
truth. Anything that only works when writes arrive through the service is
mis-designed.

## Handle resolution

Handles issued under a service's handle domain resolve because the service
publishes the records that make them resolve — a `_atproto.<handle>` DNS
TXT record containing the DID.

Two consequences for clients:

- Resolution is not instantaneous. Immediately after signup the account is
  fully usable through its own PDS while the record propagates. A client
  SHOULD present this as a pending state, not a failure, and MUST NOT block
  onboarding on it.
- A handle is a presentation attribute. Clients MUST persist the DID, or the
  AT URI for records, and never a handle or a URL as an identifier.

## What clients should persist

| Kind of value | Persist? |
|---|---|
| DID | Yes — the stable identity |
| Record AT URI | Yes — the stable record identity |
| Record CID | Yes, as the value to send back in `If-Match` |
| Handle | Cache for display only; re-read it |
| Public URL | Never as an identifier; read it from the API response |
| Session tokens | Platform secure storage only |
| Password | Never |

Public URLs are constructed by the service and returned in responses.
Clients MUST NOT assemble them from parts, because the canonical form can
change without the record changing (see `rss-atom-mapping.md`).
