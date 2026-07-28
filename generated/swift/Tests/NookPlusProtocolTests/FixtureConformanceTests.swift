import Foundation
import XCTest

@testable import NookPlusProtocol

/// Decodes every valid record fixture into the public Swift types and
/// re-encodes it, proving the Swift and Go types agree on the same wire
/// format. A field added to the Lexicons without updating these types
/// makes the round trip lossy and fails the comparison.
final class FixtureConformanceTests: XCTestCase {
    static let repoRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // FixtureConformanceTests.swift
        .deletingLastPathComponent()  // NookPlusProtocolTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // swift
        .deletingLastPathComponent()  // generated

    func fixtureURLs(_ subdirectory: String) throws -> [URL] {
        let dir = Self.repoRoot.appendingPathComponent("fixtures/\(subdirectory)")
        return try FileManager.default
            .contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    func testValidFixturesRoundTrip() throws {
        let files = try fixtureURLs("valid")
        XCTAssertFalse(files.isEmpty, "no valid fixtures found")

        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        for url in files {
            let data = try Data(contentsOf: url)
            let original = try XCTUnwrap(
                try JSONSerialization.jsonObject(with: data) as? NSDictionary,
                url.lastPathComponent
            )
            let type = try XCTUnwrap(original["$type"] as? String, url.lastPathComponent)

            let reencoded: Data
            switch type {
            case PublicationRecord.typeNSID:
                reencoded = try encoder.encode(try decoder.decode(PublicationRecord.self, from: data))
            case ArticleRecord.typeNSID:
                reencoded = try encoder.encode(try decoder.decode(ArticleRecord.self, from: data))
            default:
                XCTFail("\(url.lastPathComponent): unknown $type \(type)")
                continue
            }

            let restored = try XCTUnwrap(
                try JSONSerialization.jsonObject(with: reencoded) as? NSDictionary,
                url.lastPathComponent
            )
            XCTAssertEqual(restored, original, "\(url.lastPathComponent): round trip changed the record")
        }
    }

    func testKoreanArticleFieldsSurviveDecoding() throws {
        let url = Self.repoRoot.appendingPathComponent("fixtures/valid/article-korean.json")
        let article = try JSONDecoder().decode(ArticleRecord.self, from: Data(contentsOf: url))

        XCTAssertEqual(article.type, ArticleRecord.typeNSID)
        XCTAssertEqual(article.title, "안녕하세요, 예제 글입니다")
        XCTAssertEqual(article.slug, "korean-article")
        XCTAssertEqual(article.summary, "한국어 요약입니다.")
        XCTAssertTrue(article.publication.hasPrefix("at://did:plc:"))
    }

    func testAPITypesRoundTrip() throws {
        let signup = SignupResponse(
            did: "did:plc:aaaabbbbccccddddeeeeffff",
            handle: "alice.handles.example.com",
            session: SessionTokens(accessJwt: "synthetic-access", refreshJwt: "synthetic-refresh"),
            defaultPublication: Publication(
                uri: "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.publication/3jt5mavarik22",
                name: "Example Publication",
                slug: "example-publication",
                language: "en",
                urls: PublicationURLs(
                    page: "https://publications.example.com/@example-publication",
                    rss: "https://publications.example.com/@example-publication/feed.xml",
                    atom: "https://publications.example.com/@example-publication/atom.xml"
                )
            )
        )
        let data = try JSONEncoder().encode(signup)
        let decoded = try JSONDecoder().decode(SignupResponse.self, from: data)
        XCTAssertEqual(decoded, signup)
    }
}
