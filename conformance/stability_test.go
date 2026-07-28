package conformance

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"github.com/mmcdole/gofeed"
)

const (
	articleCreateURI = "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.article/3jt5artcreate"
	articleKoreanURI = "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.article/3jt5artkorean"
)

// itemIdentity parses a feed fixture and returns guid/id → link.
func itemIdentity(t *testing.T, format, scenario string) map[string]string {
	t.Helper()
	f, err := os.Open(filepath.Join("..", "fixtures", format, scenario+".xml"))
	if err != nil {
		t.Fatalf("opening %s/%s: %v", format, scenario, err)
	}
	defer f.Close()
	feed, err := gofeed.NewParser().Parse(f)
	if err != nil {
		t.Fatalf("parsing %s/%s: %v", format, scenario, err)
	}
	identity := make(map[string]string, len(feed.Items))
	for _, item := range feed.Items {
		identity[item.GUID] = item.Link
	}
	return identity
}

// TestItemIdentityStability asserts the core rule of docs/rss-atom-mapping.md:
// item identity (the AT URI) survives every presentation-level mutation.
func TestItemIdentityStability(t *testing.T) {
	scenarios := []string{
		"after-article-update",
		"after-publication-rename",
		"after-handle-change",
		"after-slug-change",
	}
	for _, format := range []string{"rss", "atom"} {
		baseline := itemIdentity(t, format, "baseline")
		if len(baseline) != 2 {
			t.Fatalf("%s baseline: expected 2 items, got %d", format, len(baseline))
		}
		for _, scenario := range scenarios {
			t.Run(format+"/"+scenario, func(t *testing.T) {
				mutated := itemIdentity(t, format, scenario)
				if len(mutated) != len(baseline) {
					t.Fatalf("item count changed: baseline %d, %s %d", len(baseline), scenario, len(mutated))
				}
				for guid := range baseline {
					if _, ok := mutated[guid]; !ok {
						t.Errorf("identity %s missing after %s", guid, scenario)
					}
				}
			})
		}
	}
}

func TestDeletedItemRemoved(t *testing.T) {
	for _, format := range []string{"rss", "atom"} {
		t.Run(format, func(t *testing.T) {
			after := itemIdentity(t, format, "after-article-delete")
			if _, ok := after[articleCreateURI]; ok {
				t.Errorf("deleted article %s still present", articleCreateURI)
			}
			if _, ok := after[articleKoreanURI]; !ok {
				t.Errorf("surviving article %s missing", articleKoreanURI)
			}
			if len(after) != 1 {
				t.Errorf("expected exactly 1 item after delete, got %d", len(after))
			}
		})
	}
}

func TestSlugChangeMovesLinkOnly(t *testing.T) {
	for _, format := range []string{"rss", "atom"} {
		t.Run(format, func(t *testing.T) {
			baseline := itemIdentity(t, format, "baseline")
			mutated := itemIdentity(t, format, "after-slug-change")
			if baseline[articleCreateURI] == mutated[articleCreateURI] {
				t.Error("link should change when the slug changes")
			}
			if mutated[articleCreateURI] != "https://publications.example.com/@example-publication/renamed-slug" {
				t.Errorf("unexpected link after slug change: %s", mutated[articleCreateURI])
			}
		})
	}
}

// TestHandleChangeInvisible: nothing in a feed derives from the author's
// handle, so a handle change must not alter feed output at all.
func TestHandleChangeInvisible(t *testing.T) {
	for _, format := range []string{"rss", "atom"} {
		t.Run(format, func(t *testing.T) {
			baseline, err := os.ReadFile(filepath.Join("..", "fixtures", format, "baseline.xml"))
			if err != nil {
				t.Fatal(err)
			}
			afterChange, err := os.ReadFile(filepath.Join("..", "fixtures", format, "after-handle-change.xml"))
			if err != nil {
				t.Fatal(err)
			}
			if !bytes.Equal(baseline, afterChange) {
				t.Error("after-handle-change must be byte-identical to baseline")
			}
		})
	}
}
