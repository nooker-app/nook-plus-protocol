# RSS 2.0 And Atom 1.0 Mapping

How a conforming service derives RSS 2.0 and Atom 1.0 feeds from
`app.nooker.publication` and `app.nooker.article` records. The key words
MUST, SHOULD, and MAY are used as defined in RFC 2119.

## Item Identity

Feed item identity is the article's AT URI. This is the single stability
rule everything else depends on:

- RSS: `<guid isPermaLink="false">{at-uri}</guid>`
- Atom: `<id>{at-uri}</id>` (an AT URI is a valid IRI)

The `guid`/`id` MUST NOT change when any of the following change: article
title, article slug, publication slug, publication name, the author's
handle, the base domain, or a custom domain. Feed readers deduplicate on
this value; changing it re-delivers every item.

Feed-level identity follows the same rule where the format allows it: the
Atom feed `<id>` is the publication's AT URI. RSS 2.0 has no channel id
element; the channel `<link>` is presentation-only.

## Public URLs

Presentation URLs are constructed from a deployment-configured public base
URL:

```text
{public-base-url}/@{publication-slug}                 publication page
{public-base-url}/@{publication-slug}/{article-slug}  article page
{public-base-url}/@{publication-slug}/feed.xml        RSS 2.0
{public-base-url}/@{publication-slug}/atom.xml        Atom 1.0
```

Documentation and fixtures use `https://publications.example.com` as the
base. Published feeds MUST use absolute URLs. URLs are presentation-only
and never carry identity.

## Field Mapping

### Feed / Channel

| Source | RSS 2.0 `<channel>` | Atom 1.0 `<feed>` |
|---|---|---|
| publication AT URI | — | `id` |
| `publication.name` | `title` | `title` |
| `publication.description` | `description` (empty element if absent) | `subtitle` (omit if absent) |
| publication page URL | `link` | `link rel="alternate"` |
| feed's own URL | `atom:link rel="self"` (RECOMMENDED) | `link rel="self"` |
| `publication.language` | `language` | `xml:lang` attribute (RECOMMENDED) |
| newest item timestamp | `lastBuildDate` (RECOMMENDED) | `updated` (REQUIRED) |
| author display name / profile URL | — | `author` > `name`, `uri` (feed-level) |

### Item / Entry

| Source | RSS 2.0 `<item>` | Atom 1.0 `<entry>` |
|---|---|---|
| article AT URI | `guid isPermaLink="false"` | `id` |
| `article.title` | `title` | `title` |
| article page URL | `link` | `link rel="alternate"` |
| `article.publishedAt` | `pubDate` (RFC 822) | `published` (RFC 3339) |
| `article.updatedAt`, else `publishedAt` | — | `updated` (REQUIRED) |
| `article.summary` | `description` (omit if absent) | `summary` (omit if absent) |
| rendered HTML of `article.content` | `content:encoded` (content module) | `content type="html"` |
| author display name | `dc:creator` (Dublin Core module) | `author` > `name` (entry-level, MAY be omitted when feed-level author applies) |

RSS 2.0's native `<author>` element expects an email address and MUST NOT
be used; author identification uses `dc:creator` in RSS and
`author`/`name` + `author`/`uri` in Atom. The author `uri` SHOULD be the
author's public profile or publication URL — never an email, and never a
raw DID presented as a URL.

## Content Rendering

- `article.content` is Markdown (CommonMark + GFM tables and
  strikethrough; see `lexicons.md`).
- The rendered HTML is embedded as escaped text inside `content:encoded`
  (RSS) and `content type="html"` (Atom). CDATA sections MAY be used in
  RSS; fixtures use plain escaping.
- Raw HTML inside the Markdown source MUST be sanitized or escaped —
  script, style, and event-handler content MUST NOT survive into feeds.
- Rendering MUST be deterministic: the same record and the same renderer
  version produce byte-identical HTML.

## Ordering, Size, And Updates

- Items are ordered by `publishedAt` descending; ties break by AT URI
  (ascending, byte order) so output is deterministic.
- Feeds SHOULD contain at least the 20 most recent articles. Services MAY
  include more.
- An update to an article record updates the item in place (same
  `guid`/`id`); Atom `updated` reflects `updatedAt`.
- A deleted article's item is removed from the feed entirely (see
  `deletion.md`). No tombstone entries are emitted.
- Orphaned articles (publication reference does not resolve) are excluded.

## Escaping And Encoding

- Feeds are UTF-8. `<`, `>`, `&`, and quotes in titles, summaries, and
  other text nodes MUST be XML-escaped. Fixtures include Korean text,
  emoji (including ZWJ sequences), and XML special characters.
- The literal sequence `]]>` inside content MUST not terminate a CDATA
  section (fixtures avoid CDATA to sidestep this class of bug).

## Fixture Scenarios

Each scenario pairs input records from `fixtures/valid/` with expected
output in `fixtures/rss/` and `fixtures/atom/`. Scenario inputs share the
synthetic author DID `did:plc:aaaabbbbccccddddeeeeffff`, display name
"Example Author", and base URL `https://publications.example.com`.

| Scenario | Input records | Expectation |
|---|---|---|
| `baseline` | publication-create + article-create + article-korean | Two items, ordered by `publishedAt` desc |
| `after-article-update` | baseline with article-update replacing article-create | Same `guid`/`id`; content/summary/`updated` change |
| `after-article-delete` | baseline minus article-create | Item gone; no tombstone |
| `after-publication-rename` | publication-rename + baseline articles | Channel/feed title changes; item identity unchanged |
| `after-handle-change` | baseline after the author changed handles | Byte-identical to baseline: nothing in the feed derives from the handle |
| `after-slug-change` | baseline with article slug `an-example-article` → `renamed-slug` | `link` changes; `guid`/`id` unchanged |
| `korean-emoji` | article-korean + article-emoji | UTF-8, ZWJ sequences and flags intact |
| `xml-escaping` | article-xml-special | Specials escaped in title and content |
| `markdown-rendering` | article-markdown-links-code | Links, code block, table, strikethrough rendered |

Identity stability across these scenarios is asserted by
`conformance/stability_test.go`.
