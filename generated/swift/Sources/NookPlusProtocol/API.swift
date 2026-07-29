// Public Swift types for the Nook Plus Service API.
//
// DEPRECATED as of v0.2.0, scheduled for removal in v1.0.0. These types were
// maintained by hand and never covered the whole specification. Use the
// NookPlusServiceAPI product instead, whose types and client are generated
// from openapi/openapi.yaml at build time and therefore cannot drift from it.
//
// They remain here so a v0.1.0 consumer keeps compiling while it migrates.

/// Membership state. Suspended or revoked members retain access to export
/// and deletion.
@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public enum MemberStatus: String, Codable, Sendable {
    case active, suspended, revoked
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct Member: Codable, Sendable, Equatable {
    public var did: String
    public var handle: String
    public var status: MemberStatus

    public init(did: String, handle: String, status: MemberStatus) {
        self.did = did
        self.handle = handle
        self.status = status
    }
}

/// PDS session material returned by signup. Store in the Keychain; never
/// persist elsewhere.
@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct SessionTokens: Codable, Sendable, Equatable {
    public var accessJwt: String
    public var refreshJwt: String

    public init(accessJwt: String, refreshJwt: String) {
        self.accessJwt = accessJwt
        self.refreshJwt = refreshJwt
    }
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct SignupRequest: Codable, Sendable, Equatable {
    public var invitationCode: String
    public var handle: String
    public var displayName: String?
    public var email: String
    public var password: String

    public init(invitationCode: String, handle: String, displayName: String? = nil, email: String, password: String) {
        self.invitationCode = invitationCode
        self.handle = handle
        self.displayName = displayName
        self.email = email
        self.password = password
    }
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct SignupResponse: Codable, Sendable, Equatable {
    public var did: String
    public var handle: String
    public var session: SessionTokens
    public var defaultPublication: Publication

    public init(did: String, handle: String, session: SessionTokens, defaultPublication: Publication) {
        self.did = did
        self.handle = handle
        self.session = session
        self.defaultPublication = defaultPublication
    }
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct PublicationURLs: Codable, Sendable, Equatable {
    public var page: String
    public var rss: String
    public var atom: String

    public init(page: String, rss: String, atom: String) {
        self.page = page
        self.rss = rss
        self.atom = atom
    }
}

/// A publication as returned by the service API. The AT URI is the
/// record's permanent identity.
@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct Publication: Codable, Sendable, Equatable {
    public var uri: String
    public var name: String
    public var description: String?
    public var slug: String
    public var language: String
    public var urls: PublicationURLs?

    public init(uri: String, name: String, description: String? = nil, slug: String, language: String, urls: PublicationURLs? = nil) {
        self.uri = uri
        self.name = name
        self.description = description
        self.slug = slug
        self.language = language
        self.urls = urls
    }
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct PublicationInput: Codable, Sendable, Equatable {
    public var name: String
    public var description: String?
    public var slug: String
    public var language: String

    public init(name: String, description: String? = nil, slug: String, language: String) {
        self.name = name
        self.description = description
        self.slug = slug
        self.language = language
    }
}

/// An article as returned by the service API.
@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct Article: Codable, Sendable, Equatable {
    public var uri: String
    public var publication: String
    public var title: String
    public var slug: String
    /// RFC 3339.
    public var publishedAt: String
    /// RFC 3339.
    public var updatedAt: String?
    public var url: String?

    public init(uri: String, publication: String, title: String, slug: String, publishedAt: String, updatedAt: String? = nil, url: String? = nil) {
        self.uri = uri
        self.publication = publication
        self.title = title
        self.slug = slug
        self.publishedAt = publishedAt
        self.updatedAt = updatedAt
        self.url = url
    }
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct ArticleInput: Codable, Sendable, Equatable {
    public var publication: String
    public var title: String
    public var content: String
    public var summary: String?
    public var slug: String
    /// RFC 3339. Defaults to the server's current time when omitted.
    public var publishedAt: String?

    public init(publication: String, title: String, content: String, summary: String? = nil, slug: String, publishedAt: String? = nil) {
        self.publication = publication
        self.title = title
        self.content = content
        self.summary = summary
        self.slug = slug
        self.publishedAt = publishedAt
    }
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public enum ExportJobStatus: String, Codable, Sendable {
    case pending, processing, completed, failed
}

@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct ExportJob: Codable, Sendable, Equatable {
    public var id: String
    public var status: ExportJobStatus
    public var downloadUrl: String?

    public init(id: String, status: ExportJobStatus, downloadUrl: String? = nil) {
        self.id = id
        self.status = status
        self.downloadUrl = downloadUrl
    }
}

/// RFC 7807 problem document returned for API errors.
@available(*, deprecated, message: "Use the NookPlusServiceAPI product, generated from openapi/openapi.yaml. Removed in v1.0.0.")
public struct ProblemDetails: Codable, Sendable, Equatable, Error {
    public var type: String?
    public var title: String
    public var status: Int
    public var detail: String?
    public var instance: String?

    public init(type: String? = nil, title: String, status: Int, detail: String? = nil, instance: String? = nil) {
        self.type = type
        self.title = title
        self.status = status
        self.detail = detail
        self.instance = instance
    }
}
