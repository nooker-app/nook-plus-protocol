// Public Swift types for `app.nooker` AT Protocol records.
//
// These types are maintained by hand against the Lexicon schemas in
// lexicons/ and are verified against the shared conformance fixtures by
// NookPlusProtocolTests, which fail when the types and schemas drift
// apart. Change the Lexicons first, then update these types.
//
// Timestamps are kept as RFC 3339 strings rather than Date so that
// decoding and re-encoding a record is value-preserving.

/// An `app.nooker.publication` record: a named collection of articles.
/// Presence of the record in a repository makes it public.
public struct PublicationRecord: Codable, Sendable, Equatable {
    public static let typeNSID = "app.nooker.publication"

    /// Must be `PublicationRecord.typeNSID` when the record is stored.
    public var type: String?
    public var name: String
    public var description: String?
    public var slug: String
    /// BCP-47 language tag.
    public var language: String
    /// RFC 3339.
    public var createdAt: String
    /// RFC 3339.
    public var updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case name, description, slug, language, createdAt, updatedAt
    }

    public init(
        type: String? = PublicationRecord.typeNSID,
        name: String,
        description: String? = nil,
        slug: String,
        language: String,
        createdAt: String,
        updatedAt: String? = nil
    ) {
        self.type = type
        self.name = name
        self.description = description
        self.slug = slug
        self.language = language
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// An `app.nooker.article` record: a Markdown article belonging to a
/// publication referenced by AT URI.
public struct ArticleRecord: Codable, Sendable, Equatable {
    public static let typeNSID = "app.nooker.article"

    /// Must be `ArticleRecord.typeNSID` when the record is stored.
    public var type: String?
    /// AT URI of the publication record this article belongs to.
    public var publication: String
    public var title: String
    /// Markdown (CommonMark + GFM tables and strikethrough).
    public var content: String
    public var summary: String?
    public var slug: String
    /// RFC 3339.
    public var publishedAt: String
    /// RFC 3339.
    public var updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case publication, title, content, summary, slug, publishedAt, updatedAt
    }

    public init(
        type: String? = ArticleRecord.typeNSID,
        publication: String,
        title: String,
        content: String,
        summary: String? = nil,
        slug: String,
        publishedAt: String,
        updatedAt: String? = nil
    ) {
        self.type = type
        self.publication = publication
        self.title = title
        self.content = content
        self.summary = summary
        self.slug = slug
        self.publishedAt = publishedAt
        self.updatedAt = updatedAt
    }
}
