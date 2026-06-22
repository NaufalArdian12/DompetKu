// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Dompetku",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Dompetku",
            targets: ["Dompetku"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Dompetku",
            dependencies: [],
            path: "App"
        )
    ]
)
