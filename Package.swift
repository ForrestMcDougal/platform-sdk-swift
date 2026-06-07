// swift-tools-version: 6.0

import PackageDescription

var products: [Product] = []

var packageDependencies: [Package.Dependency] = []
var coreDependencies: [Target.Dependency] = []

#if os(Linux)
packageDependencies.append(
    .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
)
coreDependencies.append(.product(name: "Crypto", package: "swift-crypto"))
coreDependencies.append(.target(name: "SwiftThreadingShim"))
#endif

var targets: [Target] = [
    .target(
        name: "YouVersionPlatformCore",
        dependencies: coreDependencies
    ),
    .testTarget(
        name: "YouVersionPlatformCoreTests",
        dependencies: ["YouVersionPlatformCore"],
        resources: [.process("Fixtures/bible_206.json")]
    ),
]

#if os(Linux)
targets.append(
    .target(
        name: "SwiftThreadingShim"
    )
)
#endif

#if !os(Linux)
targets.append(
    .target(
        name: "YouVersionPlatformUI",
        dependencies: [
            .target(name: "YouVersionPlatformCore"),
        ],
        resources: [
            .process("Resources")
        ]
    )
)
targets.append(
    .testTarget(
        name: "YouVersionPlatformUITests",
        dependencies: ["YouVersionPlatformUI"]
    )
)
// Common Prayer slim: the YouVersionPlatformReader target (a full in-SDK reader
// UI) is unused by the app and dropped to cut build time. It is a leaf — nothing
// in Core/UI depends on it. If a future need arises, restore it here, in the
// umbrella `YouVersionPlatform` dependencies, and re-add the `@_exported import`
// in Sources/YouVersionPlatformAll.
targets.append(
    .target(
        name: "YouVersionPlatform",
        dependencies: [
            .target(name: "YouVersionPlatformCore"),
            .target(name: "YouVersionPlatformUI"),
        ],
        path: "Sources/YouVersionPlatformAll"
    )
)
products.append(
    .library(
        name: "YouVersionPlatform",
        targets: ["YouVersionPlatform"]
    )
)
#else
products.append(
    .library(
        name: "YouVersionPlatformCore",
        targets: ["YouVersionPlatformCore"]
    )
)
#endif

let package = Package(
    name: "YouVersionPlatform",
    platforms: [.macOS(.v15), .iOS(.v17), .tvOS(.v18)],
    products: products,
    dependencies: packageDependencies,
    targets: targets
)
