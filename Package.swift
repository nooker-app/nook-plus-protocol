// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "nook-plus-protocol",
    platforms: [
        .macOS("26.0"),
        .iOS("18.0"),
    ],
    products: [
        .library(name: "NookPlusProtocol", targets: ["NookPlusProtocol"])
    ],
    targets: [
        .target(
            name: "NookPlusProtocol",
            path: "generated/swift/Sources/NookPlusProtocol"
        ),
        .testTarget(
            name: "NookPlusProtocolTests",
            dependencies: ["NookPlusProtocol"],
            path: "generated/swift/Tests/NookPlusProtocolTests"
        ),
    ]
)
