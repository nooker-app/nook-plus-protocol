// Transport-neutral envelopes for AT Protocol record responses.
//
// `com.atproto.repo.getRecord` and `listRecords` wrap a record value in a
// URI and CID. These generics let a client decode straight into
// `PublicationRecord` or `ArticleRecord` without a per-type wrapper, and
// without a service-specific read API standing in the way.

/// A single record as a PDS returns it.
public struct ATRecord<Value: Codable & Sendable>: Codable, Sendable, Equatable
where Value: Equatable {
    /// Permanent identity of the record.
    public var uri: String
    /// Content identifier of this revision. Send it back as `If-Match` to
    /// make a later mutation conditional.
    public var cid: String?
    public var value: Value

    public init(uri: String, cid: String? = nil, value: Value) {
        self.uri = uri
        self.cid = cid
        self.value = value
    }
}

/// One page of records, as `listRecords` returns them.
public struct ATRecordPage<Value: Codable & Sendable>: Codable, Sendable, Equatable
where Value: Equatable {
    /// Opaque continuation token. Nil or empty means this is the last page.
    public var cursor: String?
    public var records: [ATRecord<Value>]

    public init(cursor: String? = nil, records: [ATRecord<Value>]) {
        self.cursor = cursor
        self.records = records
    }

    /// Whether another page is available.
    public var hasMore: Bool {
        guard let cursor else { return false }
        return !cursor.isEmpty
    }
}

/// A page of publications.
public typealias PublicationPage = ATRecordPage<PublicationRecord>
/// A page of articles.
public typealias ArticlePage = ATRecordPage<ArticleRecord>

extension ATRecord {
    /// The record key: the last path segment of the AT URI. This is the
    /// value a permanent article alias URL is built from, and it never
    /// changes for the life of the record.
    public var recordKey: String? {
        guard let last = uri.split(separator: "/").last, !last.isEmpty else { return nil }
        return String(last)
    }

    /// The repository DID: the authority component of the AT URI.
    public var repositoryDID: String? {
        guard let withoutScheme = uri.split(separator: "//").last,
            let did = withoutScheme.split(separator: "/").first,
            did.hasPrefix("did:")
        else { return nil }
        return String(did)
    }
}
