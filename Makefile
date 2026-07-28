# Validation entry points for nook-plus-protocol.
# Targets are added as the corresponding files are introduced;
# `make verify` always runs every check that applies to the current tree.

GOAT ?= goat

.PHONY: verify lex-lint lex-breaking install-tools

verify: lex-lint lex-breaking

# Schema syntax plus lint policy (allowed warnings are documented in
# scripts/lex_lint.py and docs/lexicons.md).
lex-lint:
	GOAT=$(GOAT) python3 scripts/lex_lint.py

# Evolution-rule check against schemas published on the live network.
# NSIDs that do not resolve yet are skipped by goat.
lex-breaking:
	$(GOAT) lex breaking lexicons

install-tools:
	sh scripts/install-goat.sh
