package conformance

import (
	"bytes"
	"encoding/json"
	"os"
	"reflect"
	"testing"

	"github.com/nooker-app/nook-plus-protocol/generated/go/nookplusrecords"
)

// TestRecordTypesRoundTrip decodes every valid fixture into the public Go
// record types and re-encodes it, proving the hand-maintained types cover
// exactly the fields the Lexicons define. Unknown fields fail the decode,
// so schema additions force a type update.
func TestRecordTypesRoundTrip(t *testing.T) {
	paths := fixtureFiles(t, "valid")
	if len(paths) == 0 {
		t.Fatal("no valid fixtures found")
	}
	for _, path := range paths {
		t.Run(pathBase(path), func(t *testing.T) {
			raw, err := os.ReadFile(path)
			if err != nil {
				t.Fatal(err)
			}
			var probe struct {
				Type string `json:"$type"`
			}
			if err := json.Unmarshal(raw, &probe); err != nil {
				t.Fatal(err)
			}

			var typed any
			switch probe.Type {
			case nookplusrecords.PublicationNSID:
				typed = new(nookplusrecords.Publication)
			case nookplusrecords.ArticleNSID:
				typed = new(nookplusrecords.Article)
			default:
				t.Fatalf("unknown $type %q", probe.Type)
			}

			dec := json.NewDecoder(bytes.NewReader(raw))
			dec.DisallowUnknownFields()
			if err := dec.Decode(typed); err != nil {
				t.Fatalf("decoding into %T: %v", typed, err)
			}

			reencoded, err := json.Marshal(typed)
			if err != nil {
				t.Fatal(err)
			}
			var original, restored map[string]any
			if err := json.Unmarshal(raw, &original); err != nil {
				t.Fatal(err)
			}
			if err := json.Unmarshal(reencoded, &restored); err != nil {
				t.Fatal(err)
			}
			if !reflect.DeepEqual(original, restored) {
				t.Errorf("round trip changed the record\noriginal: %v\nrestored: %v", original, restored)
			}
		})
	}
}

func pathBase(path string) string {
	for i := len(path) - 1; i >= 0; i-- {
		if path[i] == '/' {
			return path[i+1:]
		}
	}
	return path
}
