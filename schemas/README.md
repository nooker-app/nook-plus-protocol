# Vendored XML Schemas

- `atom.rng` — RELAX NG grammar for the Atom Syndication Format
  (RFC 4287), generated from the compact-syntax grammar in the RFC's
  appendix. Vendored from <https://cweiske.de/download/atom.rng> so
  validation works offline. Used by `make xml-validate`.

RSS 2.0 has no official schema; RSS fixtures are checked for
well-formedness and parsed by a real feed parser in
`conformance/feed_test.go`.
