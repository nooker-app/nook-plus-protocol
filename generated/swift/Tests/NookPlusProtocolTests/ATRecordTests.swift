import Foundation
import XCTest

@testable import NookPlusProtocol

/// The record envelopes exist so a client can decode real PDS responses
/// without a service-specific read API. These tests use response shapes as
/// `com.atproto.repo.getRecord` and `listRecords` actually return them.
final class ATRecordTests: XCTestCase {
    func testDecodesGetRecordResponse() throws {
        let json = """
            {
              "uri": "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.publication/3jt5mavarik22",
              "cid": "bafyreiexamplecid",
              "value": {
                "$type": "app.nooker.publication",
                "name": "Example Publication",
                "slug": "example-publication",
                "language": "en",
                "createdAt": "2026-01-10T08:00:00Z"
              }
            }
            """.data(using: .utf8)!

        let record = try JSONDecoder().decode(ATRecord<PublicationRecord>.self, from: json)

        XCTAssertEqual(record.cid, "bafyreiexamplecid")
        XCTAssertEqual(record.value.name, "Example Publication")
        XCTAssertEqual(record.recordKey, "3jt5mavarik22")
        XCTAssertEqual(record.repositoryDID, "did:plc:aaaabbbbccccddddeeeeffff")
    }

    func testDecodesListRecordsResponse() throws {
        let json = """
            {
              "cursor": "3jt5artcreate",
              "records": [
                {
                  "uri": "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.article/3jt5artcreate",
                  "cid": "bafyreiarticleone",
                  "value": {
                    "$type": "app.nooker.article",
                    "publication": "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.publication/3jt5mavarik22",
                    "title": "An Example Article",
                    "content": "Hello from an example article.\\n",
                    "slug": "an-example-article",
                    "publishedAt": "2026-01-15T09:30:00Z"
                  }
                }
              ]
            }
            """.data(using: .utf8)!

        let page = try JSONDecoder().decode(ATRecordPage<ArticleRecord>.self, from: json)

        XCTAssertEqual(page.records.count, 1)
        XCTAssertTrue(page.hasMore)
        XCTAssertEqual(page.records[0].value.slug, "an-example-article")
        XCTAssertEqual(page.records[0].recordKey, "3jt5artcreate")
    }

    func testAbsentCursorMeansLastPage() throws {
        let json = #"{"records": []}"#.data(using: .utf8)!
        let page = try JSONDecoder().decode(ATRecordPage<ArticleRecord>.self, from: json)
        XCTAssertFalse(page.hasMore)

        let empty = #"{"cursor": "", "records": []}"#.data(using: .utf8)!
        XCTAssertFalse(try JSONDecoder().decode(ATRecordPage<ArticleRecord>.self, from: empty).hasMore)
    }

    /// getRecord always returns a CID, but listRecords consumers should not
    /// break if one is absent.
    func testCIDIsOptional() throws {
        let json = """
            {
              "uri": "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.publication/3jt5mavarik22",
              "value": {
                "$type": "app.nooker.publication",
                "name": "Example",
                "slug": "example",
                "language": "en",
                "createdAt": "2026-01-10T08:00:00Z"
              }
            }
            """.data(using: .utf8)!

        XCTAssertNil(try JSONDecoder().decode(ATRecord<PublicationRecord>.self, from: json).cid)
    }

    /// The record key is what a permanent article alias URL is built from, so
    /// it has to survive a round trip through the envelope untouched.
    func testRecordKeyMatchesTheFixtures() throws {
        let dir = FixtureConformanceTests.repoRoot.appendingPathComponent("fixtures/valid")
        let url = dir.appendingPathComponent("article-create.json")
        let article = try JSONDecoder().decode(ArticleRecord.self, from: Data(contentsOf: url))

        let record = ATRecord(
            uri: "at://did:plc:aaaabbbbccccddddeeeeffff/app.nooker.article/3jt5artcreate",
            cid: "bafyreiexample",
            value: article
        )
        XCTAssertEqual(record.recordKey, "3jt5artcreate")

        // Round-tripping must not disturb the value.
        let encoded = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(ATRecord<ArticleRecord>.self, from: encoded)
        XCTAssertEqual(decoded, record)
    }

    func testMalformedURIYieldsNoRecordKey() {
        let record = ATRecord(uri: "not-an-at-uri", value: 1)
        XCTAssertNil(record.repositoryDID)
    }
}
