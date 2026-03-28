// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BoteroMuseum",
    defaultLocalization: "es",
    platforms: [
        .watchOS(.v10),
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "BoteroCore", targets: ["BoteroCore"]),
        .library(name: "BoteroWatchUI", targets: ["BoteroWatchUI"]),
    ],
    targets: [
        .target(
            name: "BoteroCore",
            resources: [.process("Resources")]
        ),
        .target(
            name: "BoteroWatchUI",
            dependencies: ["BoteroCore"]
        ),
        .testTarget(
            name: "BoteroCoreTests",
            dependencies: ["BoteroCore"]
        ),
    ]
)
