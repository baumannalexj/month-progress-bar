// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MonthProgressBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MonthProgressBar", targets: ["MonthProgressBar"]),
    ],
    targets: [
        .target(name: "Models"),
        .target(name: "Api", dependencies: ["Models"]),
        .target(name: "Themes", dependencies: ["Api", "Models"]),
        .executableTarget(name: "MonthProgressBar", dependencies: ["Api", "Models", "Themes"]),
        .testTarget(name: "MonthProgressTests", dependencies: ["Models", "Themes"]),
    ]
)
