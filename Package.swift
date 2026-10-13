// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "MonthProgressBar",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "MonthProgress", targets: ["MonthProgress"]),
        .executable(name: "MonthProgressBar", targets: ["MonthProgressBar"]),
    ],
    targets: [
        .target(name: "MonthProgress"),
        .target(name: "ThemeApi", dependencies: ["MonthProgress"]),
        .target(name: "Themes", dependencies: ["MonthProgress", "ThemeApi"]),
        .executableTarget(name: "MonthProgressBar", dependencies: ["MonthProgress", "ThemeApi", "Themes"]),
        .testTarget(name: "MonthProgressTests", dependencies: ["MonthProgress"]),
    ]
)
