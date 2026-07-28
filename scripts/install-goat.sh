#!/bin/sh
# Install the pinned version of goat (Lexicon lint/validation CLI).
# https://github.com/bluesky-social/goat
set -eu

GOAT_VERSION="v0.2.3"

go install "github.com/bluesky-social/goat@${GOAT_VERSION}"
