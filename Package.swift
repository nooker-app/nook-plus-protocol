// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "nook-plus-protocol",
    platforms: [
        .macOS("26.0"),
        .iOS("18.0"),
    ],
    products: [
        // Lexicon record types and the PDS record envelopes. Hand-maintained
        // and verified against the shared fixtures.
        .library(name: "NookPlusProtocol", targets: ["NookPlusProtocol"]),
        // Service API types and client, generated from openapi/openapi.yaml
        // at build time.
        .library(name: "NookPlusServiceAPI", targets: ["NookPlusServiceAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.12.0"),
    ],
    targets: [
        .target(
            name: "NookPlusProtocol",
            path: "generated/swift/Sources/NookPlusProtocol"
        ),
        // The target's path is the openapi directory itself. That keeps the
        // canonical specification in one place: no copy, no symlink, nothing
        // to fall out of step.
        .target(
            name: "NookPlusServiceAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
            ],
            path: "openapi",
            exclude: ["README.md"],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        .testTarget(
            name: "NookPlusProtocolTests",
            dependencies: ["NookPlusProtocol"],
            path: "generated/swift/Tests/NookPlusProtocolTests"
        ),
    ]
)
