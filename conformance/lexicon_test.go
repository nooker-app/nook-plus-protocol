// Package conformance validates the canonical fixtures against the Lexicon
// schemas in lexicons/. Every fixture under fixtures/valid must validate;
// every fixture under fixtures/invalid must be rejected.
package conformance

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/bluesky-social/indigo/atproto/atdata"
	"github.com/bluesky-social/indigo/atproto/lexicon"
)

func loadCatalog(t *testing.T) *lexicon.BaseCatalog {
	t.Helper()
	cat := lexicon.NewBaseCatalog()
	if err := cat.LoadDirectory(filepath.Join("..", "lexicons")); err != nil {
		t.Fatalf("loading lexicons: %v", err)
	}
	return cat
}

// loadRecordFixture reads a fixture file containing a record body with a
// $type field identifying the record NSID.
func loadRecordFixture(t *testing.T, path string) (map[string]any, string) {
	t.Helper()
	raw, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("reading %s: %v", path, err)
	}
	// Parsed through the AT Protocol data model rather than encoding/json.
	// The two disagree on the types the model defines: a blob arrives as
	// `{"$type":"blob", ...}` and the validator expects it to have become a
	// data.Blob, which a plain map never is. Decoding a record the way the
	// protocol decodes it is also what the fixtures are meant to be checking.
	record, err := atdata.UnmarshalJSON(raw)
	if err != nil {
		t.Fatalf("parsing %s: %v", path, err)
	}
	nsid, ok := record["$type"].(string)
	if !ok || nsid == "" {
		t.Fatalf("%s: fixture record must declare $type", path)
	}
	return record, nsid
}

func fixtureFiles(t *testing.T, dir string) []string {
	t.Helper()
	paths, err := filepath.Glob(filepath.Join("..", "fixtures", dir, "*.json"))
	if err != nil {
		t.Fatalf("globbing fixtures/%s: %v", dir, err)
	}
	return paths
}

func TestValidFixtures(t *testing.T) {
	cat := loadCatalog(t)
	paths := fixtureFiles(t, "valid")
	if len(paths) == 0 {
		t.Skip("no valid fixtures present yet")
	}
	for _, path := range paths {
		t.Run(filepath.Base(path), func(t *testing.T) {
			record, nsid := loadRecordFixture(t, path)
			if err := lexicon.ValidateRecord(cat, record, nsid, 0); err != nil {
				t.Errorf("expected valid, got: %v", err)
			}
		})
	}
}

func TestInvalidFixtures(t *testing.T) {
	cat := loadCatalog(t)
	paths := fixtureFiles(t, "invalid")
	if len(paths) == 0 {
		t.Skip("no invalid fixtures present yet")
	}
	for _, path := range paths {
		t.Run(filepath.Base(path), func(t *testing.T) {
			record, nsid := loadRecordFixture(t, path)
			if err := lexicon.ValidateRecord(cat, record, nsid, 0); err == nil {
				t.Error("expected validation to fail, but record was accepted")
			} else {
				t.Logf("rejected as expected: %v", err)
			}
		})
	}
}

// TestSchemasResolve guards against schema files that fail to load or that
// drop a published definition.
func TestSchemasResolve(t *testing.T) {
	cat := loadCatalog(t)
	for _, nsid := range []string{"app.nooker.publication", "app.nooker.article"} {
		if _, err := cat.Resolve(nsid); err != nil {
			t.Errorf("resolving %s: %v", nsid, err)
		}
	}
}
