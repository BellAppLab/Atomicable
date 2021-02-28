// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Atomicable",
    products: [
        .library(name: "Atomicable",
                 targets: ["Atomicable"]),
        ],
    targets: [
        .target(
            name: "Atomicable"
        ),
        .testTarget(
            name: "AtomicableTests",
            dependencies: ["Atomicable"]),
        ],
    swiftLanguageVersions: [4.2, 5.0, 5.1, 5.2, 5.3]
)
