# Publishing Lexicons For Network Resolution

Until the `app.nooker` Lexicons are published as AT Protocol records, **this
repository is their authoritative source** and consumers read the JSON here.
Publishing makes them resolvable over the network as well, so an independent
implementation can fetch a schema without knowing about this repository.

Publishing is an operational step, not a repository change. It is not
required before this contract is usable, and it is a prerequisite for a
production beta.

## What resolution needs

An NSID resolves in two hops:

1. A DNS TXT record at `_lexicon.<authority-domain>` naming the DID that
   publishes schemas for that namespace. For `app.nooker.*` the authority
   domain is the reversed NSID authority, so the record lives at
   `_lexicon.nooker.app`.
2. A `com.atproto.lexicon.schema` record in that DID's repository, one per
   NSID, whose value is the Lexicon document.

## Procedure

Run from a clean checkout, with `goat` installed (`make install-tools`).

```sh
# 1. Confirm the local schemas are valid before publishing anything.
make lex-lint

# 2. Publish from the account that owns the namespace.
#    goat reads the schemas from lexicons/ and writes one record per NSID.
goat lex publish lexicons

# 3. Add the DNS TXT record naming the publishing DID:
#      _lexicon.<authority-domain>  TXT  "did=<publishing-did>"

# 4. Verify the network agrees with this repository.
make lex-published
```

The publishing account must stay under the operator's control for as long as
the namespace is in use: whoever holds it defines what these NSIDs mean.

## Verifying afterwards

```sh
make lex-published
```

This compares each local schema with the record resolved from the network
and reports any divergence. It is not part of `make verify`, because it
requires network access and reports nothing useful before publishing has
happened.

Divergence means a schema changed here without being republished, or the
reverse. Either way the local files remain the source of truth; republish to
close the gap.
