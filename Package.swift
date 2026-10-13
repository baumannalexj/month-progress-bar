// swift-tools-version:5.10
import PackageDescription

// Three takes on the same menu bar app, sharing the domain model and the Aqua artwork:
//   app             AppKit, hexagonal: themes are adapters that draw onto the status item
//   app-functional  AppKit shell around pure themes that return a Rendering value
//   app-declarative SwiftUI MenuBarExtra
let package = Package(
    name: "MonthProgressBar",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MonthProgressBar", targets: ["MonthProgressBar"]),
        .executable(name: "MonthProgressBarFunctional", targets: ["MonthProgressBarFunctional"]),
        .executable(name: "MonthProgressBarDeclarative", targets: ["MonthProgressBarDeclarative"]),
    ],
    targets: [
        .target(name: "Models", path: "models/src"),
        .target(name: "Artwork", path: "artwork/src"),

        .target(name: "Api", dependencies: ["Models"], path: "app/src/Api"),
        .target(name: "Themes", dependencies: ["Api", "Models", "Artwork"], path: "app/src/Themes"),
        .executableTarget(name: "MonthProgressBar", dependencies: ["Api", "Models", "Themes", "Artwork"],
                          path: "app/src", exclude: ["Api", "Themes"]),

        .target(name: "FunctionalApi", dependencies: ["Models"], path: "app-functional/src/Api"),
        .target(name: "FunctionalThemes", dependencies: ["FunctionalApi", "Models"], path: "app-functional/src/Themes"),
        .executableTarget(name: "MonthProgressBarFunctional",
                          dependencies: ["FunctionalApi", "FunctionalThemes", "Models", "Artwork"],
                          path: "app-functional/src", exclude: ["Api", "Themes"]),

        .executableTarget(name: "MonthProgressBarDeclarative", dependencies: ["Models", "Artwork"],
                          path: "app-declarative/src"),

        .testTarget(name: "MonthProgressTests", dependencies: ["Models", "Themes"], path: "tests",
                    exclude: ["functional"]),
        .testTarget(name: "FunctionalTests", dependencies: ["FunctionalApi", "FunctionalThemes", "Models"],
                    path: "tests/functional"),
    ]
)
