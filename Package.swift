// swift-tools-version:5.10
import PackageDescription

// Interfaces first: models <- api <- adapters. Themes are pure; app/src/render is the only AppKit view code;
// app/src/main is the composition root.
let package = Package(
    name: "MonthProgressBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MonthProgressBar", targets: ["MonthProgressBar"]),
    ],
    targets: [
        .target(name: "Models", path: "models"),
        .target(name: "Api", dependencies: ["Models"], path: "api"),
        .target(name: "ProgressBarThemes", dependencies: ["Api", "Models"], path: "themes/progressBar"),

        .target(name: "Clock", dependencies: ["Api", "Models"], path: "app/src/clock"),
        .target(name: "Store", dependencies: ["Api", "Models"], path: "app/src/store"),
        .target(name: "Persistence", dependencies: ["Api", "Models"], path: "app/src/persistence"),
        .target(name: "Login", dependencies: ["Api", "Models", "Persistence"], path: "app/src/login"),
        .target(name: "Render", dependencies: ["Api", "Models"], path: "app/src/render"),
        .executableTarget(name: "MonthProgressBar",
                          dependencies: ["Api", "Clock", "Login", "Models", "Persistence", "ProgressBarThemes", "Render", "Store"],
                          path: "app/src/main"),

        .testTarget(name: "MonthProgressTests",
                    dependencies: ["Api", "Clock", "Models", "ProgressBarThemes", "Render", "Store"],
                    path: "app/tests"),
    ]
)
