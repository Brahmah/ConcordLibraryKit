// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConcordLibraryKit",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ConcordLibraryKit",
            targets: ["ConcordLibraryKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup", branch: "master"),
        .package(url: "https://github.com/TelemetryDeck/SwiftClient", branch: "main"),
        .package(url: "https://github.com/dmytro-anokhin/url-image", exact: "3.1.1"),
        .package(url: "https://github.com/Lakr233/Colorful", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ConcordLibraryKit",
            dependencies: ["SwiftSoup", .product(name: "TelemetryClient", package: "SwiftClient"), .product(name: "URLImage", package: "url-image"), "Colorful", .product(name: "URLImageStore", package: "url-image")]),
        .testTarget(
            name: "ConcordLibraryKitTests",
            dependencies: ["ConcordLibraryKit"]),
    ]
)
