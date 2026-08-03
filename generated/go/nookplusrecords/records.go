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
	Icon        *Blob   `json:"icon,omitempty"`
	CreatedAt   string  `json:"createdAt"`
	UpdatedAt   *string `json:"updatedAt,omitempty"`
}

// Blob is a reference to a blob stored in the repository, as the AT Protocol
// data model represents one in JSON.
//
// Kept as its own type rather than reusing an implementation's: this package is
// the public contract, and a consumer should not have to depend on a particular
// AT Protocol library to read a record. Size is the stored blob's byte length as
// the repository reported it, not a limit.
type Blob struct {
	// Type must be "blob".
	Type     string  `json:"$type"`
	Ref      BlobRef `json:"ref"`
	MimeType string  `json:"mimeType"`
	Size     int64   `json:"size"`
}

// BlobRef holds the blob's CID under the data model's link key.
type BlobRef struct {
	Link string `json:"$link"`
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
