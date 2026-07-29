# Validation entry points for nook-plus-protocol.
# Targets are added as the corresponding files are introduced;
# `make verify` always runs every check that applies to the current tree.

GOAT ?= goat

SPECTRAL_VERSION ?= 6.15.0

.PHONY: verify lex-lint lex-breaking lex-published fixtures-test xml-validate openapi-lint generate generate-check swift-test install-tools

verify: lex-lint lex-breaking fixtures-test xml-validate openapi-lint generate-check

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

# OpenAPI contract lint (fails on warnings).
openapi-lint:
	npx --yes @stoplight/spectral-cli@$(SPECTRAL_VERSION) lint --fail-severity=warn openapi/openapi.yaml

# Regenerate the Go API model types from the OpenAPI contract.
# (The oapi-codegen version is pinned via the go.mod tool directive.)
generate:
	go tool oapi-codegen -config oapi-codegen.yaml openapi/openapi.yaml

# Fail when committed generated code is stale.
generate-check: generate
	git diff --exit-code -- generated/

# Swift package tests. Requires a Swift 6.1+ toolchain; CI runs this in a
# Swift container as a separate job from `verify`. The service API target
# generates its sources during this build, so this also proves the OpenAPI
# document produces a client that compiles.
swift-test:
	swift test

# Compare the local schemas with what the network resolves. Requires
# network access and only reports usefully once the schemas are published,
# so it stays out of `verify`. See docs/lexicon-publishing.md.
lex-published:
	$(GOAT) lex status lexicons

install-tools:
	sh scripts/install-goat.sh
