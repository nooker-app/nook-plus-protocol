# Account Lifecycle And Three Kinds Of Deletion

"Delete my stuff" means three different things, with three different
outcomes. Conflating them is how a user loses more than they intended — or
believes they deleted something they did not. Implementations MUST keep them
distinct in both API and user-facing language. The key words MUST, SHOULD,
and MAY are used as defined in RFC 2119.

| | Content deletion | Service disconnection | PDS account deletion |
|---|---|---|---|
| Publications and articles | Gone | Kept in the PDS | Gone |
| Nook membership | Kept | Gone | Kept until disconnected |
| Public pages and feeds | Gone | Gone | Gone |
| DID and handle | Kept | Kept | Gone, unrecoverable |
| Reversible? | Republish | Needs a new invitation | No |

## 1. Content deletion

The user deletes their own records. Nothing about their identity or
membership changes.

Order matters: delete articles first, then the publications, so no article
is briefly orphaned. Deleting a publication does not cascade to its
articles — see `deletion.md`.

Once the last source record is gone, service-controlled representations MUST
disappear within the documented propagation delay. Deletion MUST remain
available to suspended and revoked members: their content is theirs.

## 2. Service disconnection

The user leaves the service but keeps their PDS account, their DID, their
handle, and every record they wrote.

```text
POST /v1/service-disconnection-requests
GET  /v1/service-disconnection-requests/{requestId}
```

`POST /v1/account/deletion-requests` and its status endpoint remain as
deprecated aliases. They named the wrong thing: they never deleted an
account.

Disconnection removes membership, the service's own operational data about
the member, and every public representation the service generated. It MUST
NOT touch the PDS account or its records.

A disconnected DID is no longer an active member, so reconciliation MUST
stop converging its content. Implementations MUST drive reconciliation from
the current membership list rather than from every DID they have ever
observed — otherwise a disconnected member's records would be re-rendered
the moment a receipt expires, reversing a deletion the user asked for.

Status values are `pending`, `processing`, `completed`, and `failed`.

**Receipts.** A completed or failed request stays queryable for 24 hours,
then is hard-deleted. The receipt is a deliberate, bounded exception to
removing service-held data, so its contents are restricted to exactly:
request ID, owner DID, status, creation and completion times, and a
normalised failure code. It MUST NOT contain a handle, an email address, or
any content.

Suspended and revoked members MUST be able to request disconnection and read
its status. Reconnecting requires a new invitation or an explicit
reactivation; disconnection is not a pause.

## 3. Hosted PDS account deletion

The user destroys the account itself. The DID becomes unusable and no record
signed by it can be recovered.

This protocol defines **no endpoint for it.** Account deletion belongs to
the PDS, and duplicating it here would put a destructive operation behind a
second, less authoritative door. Clients call the PDS:

1. Export first, and complete service disconnection.
2. `com.atproto.server.requestAccountDelete` — the PDS emails a
   confirmation token.
3. `com.atproto.server.deleteAccount` with that token.

Clients MUST warn clearly that this is irreversible and that the DID cannot
be recovered.

A user may do this entirely outside any client. Reconciliation MUST detect
that the repository is gone and remove the derived representations, the same
way it handles any other disappearance of a source record.

## Ordering advice for clients

Export, then disconnect, then delete the PDS account. Reversing that order
destroys the data before the user has a copy, and a client that offers
account deletion without offering export first is doing the user a
disservice.
