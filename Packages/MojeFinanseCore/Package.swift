// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MojeFinanseCore",
    products: [
        .library(name: "MojeFinanseCore", targets: ["MojeFinanseCore"])
    ],
    targets: [
        .target(name: "MojeFinanseCore"),
        .testTarget(name: "MojeFinanseCoreTests", dependencies: ["MojeFinanseCore"])
    ]
)
