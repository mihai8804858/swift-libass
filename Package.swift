// swift-tools-version:5.9
import PackageDescription
import Foundation

func cWrapperName(_ libraryName: String) -> String {
    "C\(libraryName.capitalized)"
}

func cWrapperTarget(_ libraryName: String, linkedLibraries: [String] = []) -> Target {
    .target(
        name: cWrapperName(libraryName),
        dependencies: [.target(name: libraryName)],
        path: "Sources/C/\(cWrapperName(libraryName))",
        cSettings: [.headerSearchPath("../../../Libraries/**")],
        linkerSettings: linkedLibraries.map { .linkedLibrary($0) }
    )
}

func binaryTarget(_ libraryName: String) -> Target {
    .binaryTarget(
        name: libraryName,
        path: "Libraries/\(libraryName).xcframework"
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
                .target(name: cWrapperName("fontconfig")),
                .target(name: cWrapperName("freetype")),
                .target(name: cWrapperName("harfbuzz")),
                .target(name: cWrapperName("fribidi")),
                .target(name: cWrapperName("libpng")),
                .target(name: cWrapperName("libass"))
            ],
            path: "Sources/Swift",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
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
        binaryTarget("libass"),
        // C Wrapper Targets
        cWrapperTarget("fontconfig"),
        cWrapperTarget("freetype"),
        cWrapperTarget("harfbuzz"),
        cWrapperTarget("fribidi"),
        cWrapperTarget("libpng"),
        cWrapperTarget("libass", linkedLibraries: [
            "expat",
            "iconv",
            "z",
            "m"
        ])
    ]
)
