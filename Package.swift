// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ValidationCore",
    platforms: [
        .iOS(.v12),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ValidationCore",
            targets: ["ValidationCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ehn-digital-green-development/base45-swift", .branch("main")),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .upToNextMajor(from: "3.7.0")),
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", .upToNextMajor(from: "5.1.1")),
        .package(url: "https://github.com/eu-digital-green-certificates/SwiftCBOR", .branch("master")),
        .package(url: "https://github.com/filom/ASN1Decoder", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "3.1.2")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", .upToNextMajor(from: "9.1.0")),
    ],
    targets: [
        .target(
            name: "ValidationCore",
            dependencies: ["base45-swift",
                           .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                           "ASN1Decoder",
                           "Gzip",
                           "SwiftCBOR"
            ]),
        .testTarget(
            name: "ValidationCoreTests",
            dependencies: ["ValidationCore", "Nimble", "Quick", .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")],
            resources: [.copy("Testdata")]
            ),
    ]
)
