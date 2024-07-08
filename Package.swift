// swift-tools-version:5.9
import PackageDescription
import Foundation

func binaryTarget(_ libraryName: String) -> Target {
    .binaryTarget(
        name: libraryName,
        path: "Libraries/XCFrameworks/\(libraryName).xcframework"
    )
}

let package = Package(
    name: "swift-libass",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .visionOS(.v1),
        .macOS(.v12),
        .macCatalyst(.v15)
    ],
    products: [
        .library(name: "SwiftLibass", targets: ["SwiftLibass"])
    ],
    targets: [
        // Swift Targets
        .target(
            name: "SwiftLibass",
            dependencies: [
                .target(name: "fontconfig"),
                .target(name: "freetype"),
                .target(name: "harfbuzz"),
                .target(name: "fribidi"),
                .target(name: "libpng"),
                .target(name: "libass")
            ],
            path: "Sources",
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedLibrary("fontconfig"),
                .linkedLibrary("freetype"),
                .linkedLibrary("harfbuzz"),
                .linkedLibrary("fribidi"),
                .linkedLibrary("png16"),
                .linkedLibrary("ass"),
                .linkedLibrary("expat"),
                .linkedLibrary("iconv"),
                .linkedLibrary("z"),
                .linkedLibrary("m")
            ]
        ),
        .testTarget(
            name: "SwiftLibassTests",
            dependencies: [.target(name: "SwiftLibass")],
            path: "Tests"
        ),
        // Binary Targets
        binaryTarget("fontconfig"),
        binaryTarget("freetype"),
        binaryTarget("harfbuzz"),
        binaryTarget("fribidi"),
        binaryTarget("libpng"),
        binaryTarget("libass")
    ]
)
