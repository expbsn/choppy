// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ChoppyCore",
    defaultLocalization: "de",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "ChoppyCore", targets: ["ChoppyCore"]),
    ],
    targets: [
        .target(name: "ChoppyCore"),
        .testTarget(name: "ChoppyCoreTests", dependencies: ["ChoppyCore"]),
    ]
)
