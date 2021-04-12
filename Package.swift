// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ValidationCore",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "ValidationCore",
            targets: ["ValidationCore"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../base45-swift/"),
        .package(path: "../CBORSwift/"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.0"),
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", from: "5.1.1"),
        .package(url: "https://github.com/unrelentingtech/SwiftCBOR", from: "0.4.3"),
    ],
    targets: [
        .target(
            name: "ValidationCore",
            dependencies: ["base45-swift",
                           .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                           "Gzip",
                           "SwiftCBOR",
                           "CBORSwift"]),
        .testTarget(
            name: "ValidationCoreTests",
            dependencies: ["ValidationCore"]),
    ]
)
