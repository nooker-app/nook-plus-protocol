# Validation entry points for nook-plus-protocol.
# Targets are added as the corresponding files are introduced;
# `make verify` always runs every check that applies to the current tree.

GOAT ?= goat

.PHONY: verify lex-lint lex-breaking fixtures-test xml-validate install-tools

verify: lex-lint lex-breaking fixtures-test xml-validate

# Schema syntax plus lint policy (allowed warnings are documented in
# scripts/lex_lint.py and docs/lexicons.md).
lex-lint:
	GOAT=$(GOAT) python3 scripts/lex_lint.py

# Evolution-rule check against schemas published on the live network.
# NSIDs that do not resolve yet are skipped by goat.
lex-breaking:
	$(GOAT) lex breaking lexicons

# Record fixtures against the Lexicon schemas (valid must pass, invalid must fail).
fixtures-test:
	go test ./conformance/...

# Feed fixtures: XML well-formedness for both formats, plus the vendored
# RFC 4287 RelaxNG schema for Atom. (RSS 2.0 has no official schema; RSS
# structure is exercised by a real parser in conformance/feed_test.go.)
xml-validate:
	xmllint --noout fixtures/rss/*.xml fixtures/atom/*.xml
	xmllint --noout --relaxng schemas/atom.rng fixtures/atom/*.xml

install-tools:
	sh scripts/install-goat.sh
