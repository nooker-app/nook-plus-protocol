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
    /// Optional icon for the publication, used as the favicon of its pages and
    /// as its feed image. The stored blob is the source image; an implementation
    /// resizes and re-encodes it for delivery.
    public var icon: Blob?
    /// RFC 3339.
    public var createdAt: String
    /// RFC 3339.
    public var updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case name, description, slug, language, icon, createdAt, updatedAt
    }

    public init(
        type: String? = PublicationRecord.typeNSID,
        name: String,
        description: String? = nil,
        slug: String,
        language: String,
        icon: Blob? = nil,
        createdAt: String,
        updatedAt: String? = nil
    ) {
        self.type = type
        self.name = name
        self.description = description
        self.slug = slug
        self.language = language
        self.icon = icon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// A reference to a blob stored in the repository, as the AT Protocol data model
/// represents one in JSON.
///
/// Its own type rather than one borrowed from an AT Protocol library: this
/// package is the public contract, and reading a record should not require
/// depending on a particular implementation. `size` is the stored blob's byte
/// length as the repository reported it, not a limit.
public struct Blob: Codable, Sendable, Equatable {
    /// Must be `"blob"`.
    public var type: String
    public var ref: Ref
    public var mimeType: String
    public var size: Int

    /// Holds the blob's CID under the data model's link key.
    public struct Ref: Codable, Sendable, Equatable {
        public var link: String

        private enum CodingKeys: String, CodingKey {
            case link = "$link"
        }

        public init(link: String) {
            self.link = link
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case ref, mimeType, size
    }

    public init(type: String = "blob", ref: Ref, mimeType: String, size: Int) {
        self.type = type
        self.ref = ref
        self.mimeType = mimeType
        self.size = size
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
