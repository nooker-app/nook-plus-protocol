# AGENTS.md

## Scope

These instructions apply to the entire repository.

## Communication And Workflow

- Reply in Korean unless the user explicitly asks for another language.
- Work directly on `main` unless the user asks for a different workflow.
- Before editing, run `git status --short --branch` and preserve unrelated user changes.
- Do not create feature branches or pull requests by default.
- Stage only files related to the task. Run the relevant validation commands and `git diff --check` before committing.
- Commit completed work with a concise conventional commit message and push to `origin/main`, unless the user says otherwise.
- Include this trailer in commits created by Codex:

  ```text
  Co-authored-by: Codex <noreply@openai.com>
  ```

## Repository Purpose

This repository defines the public interoperability surface for publishing Nook content through AT Protocol and syndication formats.

Keep it suitable for independent implementers. Its schemas, examples, and documentation must be understandable without access to any particular service implementation.

Expected contents include:

- AT Protocol Lexicons for publications and articles.
- Public HTTP API contracts when a stable public contract is needed.
- RSS and Atom output requirements.
- Canonical fixtures and conformance examples.
- Generated protocol types intended for public consumption.
- Documentation for identity, ownership, deletion, versioning, and interoperability.

Do not place credentials, deployment configuration, operational runbooks, customer data, or environment-specific infrastructure details in this repository.

## Product And Protocol Principles

- The user's PDS records are the authoritative source for user-authored publications and articles.
- A user's identity is represented by a DID. Handles and display names are mutable labels, not stable identifiers.
- Users must be able to publish their content through AT Protocol and through RSS/Atom representations.
- Deleting a source record must make it disappear from Nook-controlled public representations after the documented propagation delay.
- Never claim that deletion can retract copies already fetched or retained by third parties.
- Nook-specific indexes, caches, rendered pages, and feeds are derived data and must be rebuildable from authoritative records plus the minimum required service metadata.
- Version 1 article content is Markdown text. Do not add image or media semantics without an explicit protocol revision.
- Custom domains may change public presentation URLs, but must not change record ownership or canonical DID identity.

## Current Namespace And Records

- Use the `app.nooker` namespace for Nook-owned Lexicons.
- The initial record types are `app.nooker.publication` and `app.nooker.article`.
- Preserve the distinction between a publication and its articles. Articles should reference their publication using stable AT Protocol identifiers rather than presentation URLs.
- Treat record keys, AT URIs, CIDs, and DIDs according to AT Protocol semantics. Do not invent incompatible identifier formats.

## Schema Design Rules

- Lexicons are the canonical machine-readable contract. Keep prose documentation and generated types aligned with them.
- Prefer additive, backward-compatible evolution. Do not rename or remove published fields without an explicit migration and versioning plan.
- Mark optional fields as optional and define defaults in documentation rather than relying on a single implementation's behavior.
- Define length, format, and validation constraints explicitly where interoperability depends on them.
- Use standard formats such as RFC 3339 timestamps and absolute HTTPS URLs where applicable.
- Do not embed service-specific database IDs, storage paths, queue names, or internal authorization roles in public records.
- Keep records portable between conforming PDS hosts.
- When a schema change affects RSS, Atom, or HTTP representations, update all affected examples and conformance fixtures in the same change.

## Ownership And Deletion Semantics

- User-authored content belongs in user-controlled AT Protocol records, not solely in a service database.
- Document which metadata is authoritative, which is derived, and which is presentation-only.
- A source-record deletion is the deletion authority. Implementations may process it asynchronously, but the expected upper bound must be documented.
- Fixtures must cover create, update, delete, handle change, publication rename, and missing-reference behavior.
- Export and migration documentation must avoid assumptions about a single hosting provider.

## RSS And Atom Compatibility

- Emit valid, standards-compatible RSS 2.0 and Atom 1.0 examples.
- Preserve stable item identity across title, slug, handle, domain, and rendering changes.
- Use absolute URLs in published feeds.
- Escape XML correctly and include tests or fixtures for Markdown, HTML entities, Unicode, and Korean text.
- Keep feed ordering, timestamps, update behavior, and deletion behavior deterministic and documented.

## Generated Code

- Generated files must identify their source and generation command.
- Do not hand-edit generated files. Change the Lexicon or generator and regenerate them.
- Generation must be deterministic so a clean checkout can reproduce committed output.
- Keep generated APIs small and free from dependencies on a specific server architecture.

## Documentation Standards

- Write normative requirements with clear terms such as MUST, SHOULD, and MAY only when their meaning is intentional.
- Distinguish protocol guarantees from examples and implementation guidance.
- Never document an unreleased field or behavior as stable.
- Public examples must use reserved example domains and obviously synthetic DIDs, handles, emails, and content.
- Do not include credentials, project IDs, account identifiers, non-public URLs, customer data, or operational deployment details in documentation, fixtures, commit messages, or generated artifacts.

## Validation

Add repository-specific commands to this section when the toolchain is introduced. At minimum, changes should eventually verify:

- Lexicon syntax and namespace validity.
- Generated code is up to date.
- JSON fixtures match their schemas.
- RSS and Atom fixtures parse successfully.
- Markdown, XML escaping, Unicode, and deletion cases are covered.
- Documentation links and examples remain valid.
