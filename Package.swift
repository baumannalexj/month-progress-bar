// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MonthProgressBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MonthProgressBar", targets: ["MonthProgressBar"]),
    ],
    targets: [
        .target(name: "Api"),
        .target(name: "Themes", dependencies: ["Api"]),
        .executableTarget(name: "MonthProgressBar", dependencies: ["Api", "Themes"]),
        .testTarget(name: "MonthProgressTests", dependencies: ["Api", "Themes"]),
    ]
)
