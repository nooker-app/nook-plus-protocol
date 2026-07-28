// Package nookplusrecords provides the public Go types for `app.nooker`
// AT Protocol records.
//
// These types are maintained by hand against the Lexicon schemas in
// lexicons/ and are verified against the conformance fixtures by
// conformance/records_test.go, which fails when the types and schemas
// drift apart. Change the Lexicons first, then update these types.
//
// Timestamps are kept as RFC 3339 strings rather than time.Time so that
// decoding and re-encoding a record is byte-preserving.
package nookplusrecords

// NSIDs of the record collections.
const (
	PublicationNSID = "app.nooker.publication"
	ArticleNSID     = "app.nooker.article"
)

// Publication is an app.nooker.publication record: a named collection of
// articles. Presence of the record in a repository makes it public.
type Publication struct {
	// Type must be PublicationNSID when the record is stored.
	Type        string  `json:"$type,omitempty"`
	Name        string  `json:"name"`
	Description *string `json:"description,omitempty"`
	Slug        string  `json:"slug"`
	Language    string  `json:"language"`
	CreatedAt   string  `json:"createdAt"`
	UpdatedAt   *string `json:"updatedAt,omitempty"`
}

// Article is an app.nooker.article record: a Markdown article belonging to
// a publication referenced by AT URI.
type Article struct {
	// Type must be ArticleNSID when the record is stored.
	Type        string  `json:"$type,omitempty"`
	Publication string  `json:"publication"`
	Title       string  `json:"title"`
	Content     string  `json:"content"`
	Summary     *string `json:"summary,omitempty"`
	Slug        string  `json:"slug"`
	PublishedAt string  `json:"publishedAt"`
	UpdatedAt   *string `json:"updatedAt,omitempty"`
}
