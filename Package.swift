// swift-tools-version:5.10
import PackageDescription

// Functional core, hexagonal shape: models <- api <- themes are pure; app/src/controller is the AppKit shell,
// app/src/main the composition root.
let package = Package(
    name: "MonthProgressBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MonthProgressBar", targets: ["MonthProgressBar"]),
    ],
    targets: [
        .target(name: "Models", path: "models"),
        .target(name: "Api", dependencies: ["Models"], path: "api"),
        .target(name: "Themes", dependencies: ["Api", "Models"], path: "themes"),
        .target(name: "Controller", dependencies: ["Api", "Models"], path: "app/src/controller"),
        .executableTarget(name: "MonthProgressBar", dependencies: ["Api", "Controller", "Models", "Themes"],
                          path: "app/src/main"),
        .testTarget(name: "MonthProgressTests", dependencies: ["Api", "Controller", "Models", "Themes"], path: "app/tests"),
    ]
)
