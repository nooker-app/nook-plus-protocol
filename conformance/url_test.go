package conformance

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/mmcdole/gofeed"
)

// Article URLs come in two forms per docs/rss-atom-mapping.md: a canonical
// slug URL and a permanent record-key alias. These tests fix the property
// that matters — the alias is derivable from item identity alone, so it
// cannot be affected by any presentation change.

var atURIPattern = regexp.MustCompile(`^at://(did:[^/]+)/([^/]+)/([^/]+)$`)

// aliasPath derives the permanent alias path from an item's identity and its
// publication slug, mirroring what a conforming service must serve.
func aliasPath(t *testing.T, atURI, publicationSlug string) string {
	t.Helper()
	parts := atURIPattern.FindStringSubmatch(atURI)
	if parts == nil {
		t.Fatalf("item identity %q is not an AT URI", atURI)
	}
	return "/@" + publicationSlug + "/" + parts[3]
}

// publicationSlugFromLink reads the publication slug out of an article link,
// which is the only place a feed carries it.
func publicationSlugFromLink(t *testing.T, link string) string {
	t.Helper()
	_, after, found := strings.Cut(link, "/@")
	if !found {
		t.Fatalf("link %q has no /@publication segment", link)
	}
	slug, _, found := strings.Cut(after, "/")
	if !found {
		t.Fatalf("link %q has no article segment", link)
	}
	return slug
}

func feedItems(t *testing.T, format, scenario string) []*gofeed.Item {
	t.Helper()
	path := filepath.Join("..", "fixtures", format, scenario+".xml")
	f, err := os.Open(path)
	if err != nil {
		t.Fatalf("opening %s: %v", path, err)
	}
	defer f.Close()

	feed, err := gofeed.NewParser().Parse(f)
	if err != nil {
		t.Fatalf("parsing %s: %v", path, err)
	}
	return feed.Items
}

// The canonical link is the slug form. A record key would be opaque, and
// these are published URLs for a reading product.
func TestArticleLinksUseTheSlugForm(t *testing.T) {
	for _, format := range []string{"rss", "atom"} {
		for _, item := range feedItems(t, format, "baseline") {
			alias := aliasPath(t, item.GUID, publicationSlugFromLink(t, item.Link))
			if strings.HasSuffix(item.Link, alias) {
				t.Errorf("%s: link %q uses the record-key form; the canonical form is the slug",
					format, item.Link)
			}
		}
	}
}

// The point of the alias: a slug change moves the canonical link, and the
// alias stays put. Without this property a slug edited directly through the
// PDS would break every existing link.
func TestRecordKeyAliasSurvivesASlugChange(t *testing.T) {
	for _, format := range []string{"rss", "atom"} {
		t.Run(format, func(t *testing.T) {
			before := map[string]string{}
			for _, item := range feedItems(t, format, "baseline") {
				before[item.GUID] = item.Link
			}

			movedCanonical := false
			for _, item := range feedItems(t, format, "after-slug-change") {
				priorLink, known := before[item.GUID]
				if !known {
					t.Fatalf("item %q appeared out of nowhere", item.GUID)
				}

				priorSlug := publicationSlugFromLink(t, priorLink)
				currentSlug := publicationSlugFromLink(t, item.Link)
				if aliasPath(t, item.GUID, priorSlug) != aliasPath(t, item.GUID, currentSlug) {
					t.Errorf("alias changed for %q", item.GUID)
				}
				if priorLink != item.Link {
					movedCanonical = true
				}
			}

			if !movedCanonical {
				t.Error("the scenario should change at least one canonical link")
			}
		})
	}
}

// Identity is the AT URI, so the alias derived from it must be stable across
// every presentation change the fixtures cover.
func TestRecordKeyAliasIsStableAcrossPresentationChanges(t *testing.T) {
	scenarios := []string{
		"after-slug-change",
		"after-publication-rename",
		"after-handle-change",
		"after-article-update",
	}

	for _, format := range []string{"rss", "atom"} {
		baseline := map[string]string{}
		for _, item := range feedItems(t, format, "baseline") {
			baseline[item.GUID] = aliasPath(t, item.GUID, publicationSlugFromLink(t, item.Link))
		}

		for _, scenario := range scenarios {
			t.Run(format+"/"+scenario, func(t *testing.T) {
				for _, item := range feedItems(t, format, scenario) {
					want, known := baseline[item.GUID]
					if !known {
						continue
					}
					got := aliasPath(t, item.GUID, publicationSlugFromLink(t, item.Link))
					if got != want {
						t.Errorf("alias for %q changed: %q -> %q", item.GUID, want, got)
					}
				}
			})
		}
	}
}
