// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "physix2",
    products: [
        .executable(name: "physix2", targets: ["physix2"])
    ],
    dependencies: [
        .package(name: "JavaScriptKit", url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "physix2",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit")
            ]),
        .testTarget(
            name: "physix2Tests",
            dependencies: ["physix2"]),
    ]
)