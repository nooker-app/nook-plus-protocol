# Changelog

Repository releases are semantic version tags describing the repository and
its generated artifacts; see `docs/versioning.md`.

## Unreleased (targeting v0.1.0)

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
