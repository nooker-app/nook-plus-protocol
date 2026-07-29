// Hand-written companion to the generated service API.
//
// The generated code models the OpenAPI document faithfully, which leaves
// `Problem.type` as a plain string. These are the fixed identifiers a
// conforming service emits, so matching on them belongs here rather than as
// string literals at each call site.
//
// This file also gives the target a Swift source of its own; the rest of the
// module is generated at build time from openapi.yaml in this directory.

/// Stable problem types returned by the service API.
///
/// Every conforming implementation emits these exact values regardless of
/// the domain it is deployed on, and they are not required to be
/// dereferenceable. Match on them; never on `detail`, which is unstable
/// prose.
public enum ProblemType: String, Codable, Sendable, CaseIterable {
    case invalidInvitation = "https://nooker.app/problems/invalid-invitation"
    case handleUnavailable = "https://nooker.app/problems/handle-unavailable"
    case slugUnavailable = "https://nooker.app/problems/slug-unavailable"
    case memberSuspended = "https://nooker.app/problems/member-suspended"
    case memberRevoked = "https://nooker.app/problems/member-revoked"
    case recordNotFound = "https://nooker.app/problems/record-not-found"
    case recordConflict = "https://nooker.app/problems/record-conflict"
    case invalidRecord = "https://nooker.app/problems/invalid-record"
    case invalidRequest = "https://nooker.app/problems/invalid-request"
    case invalidSession = "https://nooker.app/problems/invalid-session"
    case idempotencyConflict = "https://nooker.app/problems/idempotency-conflict"
    case rateLimited = "https://nooker.app/problems/rate-limited"
    case pdsUnavailable = "https://nooker.app/problems/pds-unavailable"

    /// Whether the user can plausibly fix this themselves. Drives whether a
    /// client shows a corrective prompt or an operational message.
    public var isUserCorrectable: Bool {
        switch self {
        case .invalidInvitation, .handleUnavailable, .slugUnavailable,
            .recordConflict, .invalidRecord, .invalidRequest, .invalidSession,
            .idempotencyConflict:
            return true
        case .memberSuspended, .memberRevoked, .recordNotFound, .rateLimited,
            .pdsUnavailable:
            return false
        }
    }

    /// Whether repeating the identical request could succeed.
    ///
    /// `recordConflict` is deliberately false: the point of a conditional
    /// mutation is that the client re-reads and reconciles first. Retrying
    /// unchanged either fails again or, worse, succeeds after the client
    /// drops the condition and overwrites someone's change.
    public var isRetryableUnchanged: Bool {
        switch self {
        case .rateLimited, .pdsUnavailable:
            return true
        default:
            return false
        }
    }
}

extension ProblemType {
    /// Interprets a raw `type` value, tolerating one this build does not
    /// know. A client must keep working when a service adds a type, so an
    /// unrecognised value is nil rather than an error.
    public init?(unchecked rawValue: String?) {
        guard let rawValue, let known = ProblemType(rawValue: rawValue) else {
            return nil
        }
        self = known
    }
}
