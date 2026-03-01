// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
// Only for development checks
//    SwiftSetting.unsafeFlags([
//        "-Xfrontend", "-strict-concurrency=complete",
//        "-Xfrontend", "-warn-concurrency",
//        "-Xfrontend", "-enable-actor-data-race-checks",
//    ])
]

let package = Package(
    name: "ForestryLogger",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "ForestryLoggerLibrary", targets: ["ForestryLoggerLibrary"]),
        .library(name: "ForestryFileLogger", targets: ["ForestryFileLogger"]),
        .library(name: "ForestrySwiftyBeaverSupport", targets: ["ForestrySwiftyBeaverSupport"]),
        .library(name: "ForestryLogRocketSupport", targets: ["ForestryLogRocketSupport"]),
        .library(name: "ForestrySentrySupport", targets: ["ForestrySentrySupport"]),
        .library(name: "ForestryDatadogSupport", targets: ["ForestryDatadogSupport"]),
        .library(name: "ForestryOSLogSupport", targets: ["ForestryOSLogSupport"])
    ],
    dependencies: [
        .package(url: "https://github.com/DataDog/dd-sdk-ios", Version(2,7,1)..<Version(4,0,0)),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", .upToNextMajor(from: .init(1, 9, 6))),
        .package(url: "https://github.com/LogRocket/logrocket-ios-swift-package", .upToNextMajor(from: .init(1, 12, 0))),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", Version(8,3,0)..<Version(10,0,0)),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
    ],
    targets: [
        .target(name: "ForestryLoggerLibrary", dependencies: []),
        .target(name: "ForestryFileLogger", dependencies: ["ForestryLoggerLibrary"]),
        .target(name: "ForestrySwiftyBeaverSupport",
                dependencies: [
                    .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
                    .target(name: "ForestryLoggerLibrary")
                ],
               swiftSettings: swiftSettings),
        .target(name: "ForestryLogRocketSupport",
                dependencies: [
                    .product(name: "LogRocket", package: "logrocket-ios-swift-package", condition: .when(platforms: [.iOS, .macCatalyst])),
                    .target(name: "ForestryLoggerLibrary")
                ]),
        .target(name: "ForestrySentrySupport",
                dependencies: [
                    .product(name: "Sentry", package: "sentry-cocoa"),
                    .target(name: "ForestryLoggerLibrary")
                ],
                swiftSettings: swiftSettings),
        .target(name: "ForestryOSLogSupport",
                dependencies: [
                    .target(name: "ForestryLoggerLibrary")
                ],
                swiftSettings: swiftSettings),
        .target(name: "ForestryDatadogSupport",
                dependencies: [
                    .product(name: "DatadogCore", package: "dd-sdk-ios", condition: .when(platforms: [.iOS, .macCatalyst])),
                    .product(name: "DatadogLogs", package: "dd-sdk-ios", condition: .when(platforms: [.iOS, .macCatalyst])),
                    .target(name: "ForestryLoggerLibrary")
                ],
                swiftSettings: swiftSettings),
        .testTarget(name: "ForestryLoggerLibraryTests", 
                    dependencies: ["ForestryLoggerLibrary"],
                    swiftSettings: swiftSettings)
    ]
)
