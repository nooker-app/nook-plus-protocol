package conformance

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/mmcdole/gofeed"
)

// TestFeedFixturesParse confirms every RSS/Atom fixture parses with a real
// feed consumer and carries AT-URI item identity as required by
// docs/rss-atom-mapping.md.
func TestFeedFixturesParse(t *testing.T) {
	for _, dir := range []string{"rss", "atom"} {
		paths, err := filepath.Glob(filepath.Join("..", "fixtures", dir, "*.xml"))
		if err != nil {
			t.Fatalf("globbing fixtures/%s: %v", dir, err)
		}
		if len(paths) == 0 {
			t.Fatalf("no %s fixtures found", dir)
		}
		for _, path := range paths {
			t.Run(dir+"/"+filepath.Base(path), func(t *testing.T) {
				f, err := os.Open(path)
				if err != nil {
					t.Fatalf("opening: %v", err)
				}
				defer f.Close()

				feed, err := gofeed.NewParser().Parse(f)
				if err != nil {
					t.Fatalf("parsing: %v", err)
				}
				if feed.Title == "" {
					t.Error("feed has no title")
				}
				if len(feed.Items) == 0 {
					t.Error("feed has no items")
				}
				for _, item := range feed.Items {
					if !strings.HasPrefix(item.GUID, "at://") {
						t.Errorf("item %q: identity %q is not an AT URI", item.Title, item.GUID)
					}
					if item.Link == "" || !strings.HasPrefix(item.Link, "https://") {
						t.Errorf("item %q: link %q is not an absolute HTTPS URL", item.Title, item.Link)
					}
					if item.PublishedParsed == nil {
						t.Errorf("item %q: publication date missing or unparsable", item.Title)
					}
				}
			})
		}
	}
}
