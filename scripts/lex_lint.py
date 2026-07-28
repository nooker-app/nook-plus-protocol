#!/usr/bin/env python3
"""Lint Lexicon schemas with goat and enforce this repository's lint policy.

Policy: any finding fails the check unless it is in ALLOWED_WARNINGS, a
documented list of intentional deviations.
"""

import json
import os
import pathlib
import subprocess
import sys

# (nsid, lint-name) pairs that are intentional and documented.
ALLOWED_WARNINGS = {
    # article.content is deliberately a large Markdown text field (100 KB,
    # matching existing AT Protocol long-form writing). Blob storage is out
    # of scope for this protocol revision; see docs/lexicons.md.
    ("app.nooker.article", "large-string"),
}


def main() -> int:
    goat = os.environ.get("GOAT", "goat")

    schema_files = sorted(str(p) for p in pathlib.Path("lexicons").rglob("*.json"))
    if not schema_files:
        print("lex-lint: no schema files found under lexicons/", file=sys.stderr)
        return 1

    parse = subprocess.run([goat, "lex", "parse", *schema_files])
    if parse.returncode != 0:
        print("lex-lint: schema parse failed", file=sys.stderr)
        return 1

    lint = subprocess.run(
        [goat, "lex", "lint", "--json", "lexicons"],
        capture_output=True,
        text=True,
    )
    failures = []
    for line in lint.stdout.splitlines():
        line = line.strip()
        if not line.startswith("{"):
            continue
        finding = json.loads(line)
        key = (finding.get("nsid"), finding.get("lint-name"))
        if finding.get("lint-level") == "warn" and key in ALLOWED_WARNINGS:
            print(f"lex-lint: allowed warning {key[0]}: {key[1]}")
            continue
        failures.append(finding)

    for finding in failures:
        print(f"lex-lint: {finding}", file=sys.stderr)
    if failures:
        return 1
    print("lex-lint: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
