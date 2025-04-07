// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
/// use local package path
let packageLocal: Bool = false
let environmentUIPackageLocal: Bool = false
let districtPackageLocal: Bool = false

let oscaSolingenVersion = Version("3.8.0")
let oscaEssentialsVersion = Version("1.1.0")
let oscaNetworkServiceVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let oscaSafariViewVersion = Version("1.1.0")
let oscaContactVersion = Version("1.1.0")
let oscaContactUIVersion = Version("1.1.0")
let oscaCoronaVersion = Version("1.0.0")
let oscaCoronaUIVersion = Version("1.0.0")
let oscaCoworkingVersion = Version("1.1.0")
let oscaCoworkingUIVersion = Version("1.1.0")
let oscaCultureVersion = Version("1.1.0")
let oscaCultureUIVersion = Version("1.2.0")
let oscaDefectVersion = Version("1.1.0")
let oscaDefectUIVersion = Version("1.1.0")
let oscaDistrictVersion = Version("1.5.5")
let oscaEnvironmentUIVersion = Version("1.2.0")
let oscaEventsVersion = Version("1.2.0")
let oscaEventsUIVersion = Version("1.2.0")
let oscaJobsVersion = Version("1.1.0")
let oscaJobsUIVersion = Version("1.1.0")
let oscaMapVersion = Version("1.1.0")
let oscaMapUIVersion = Version("1.2.0")
let oscaPressReleasesVersion = Version("1.1.0")
let oscaPressReleasesUIVersion = Version("1.1.0")
let oscaPublicTransportVersion = Version("1.1.0")
let oscaPublicTransportUIVersion = Version("1.1.0")
let oscaWasteVersion = Version("1.4.1")
let oscaWasteUIVersion = Version("1.6.1")
let oscaWeatherVersion = Version("1.1.0")
let oscaWeatherUIVersion = Version("1.1.0")
let oscaMobilityVersion = Version("1.1.0")
let oscaMobilityUIVersion = Version("1.1.0")
let swiftSoupVersion = Version("2.4.3")
let matomoVersion = Version("7.7.0")
let skyFloatingLabelTextFieldVersion = Version("3.8.0")
let swiftSpinnerVersion = Version("2.2.0")
let deviceKitVersion = Version("5.0.0")
let swiftDateVersion = Version("7.0.0")
let atomicsVersion = Version("1.0.0")
let chartsVersion = Version("5.0.0")

let package = Package(
  name: "OSCASolingen",
  defaultLocalization: "de",
  platforms: [.iOS(.v15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(name: "OSCASolingen",
             targets: ["OSCASolingen"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    /* OSCASafariView */
    packageLocal ? .package(path: "modules/OSCASafariView") :
        .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscasafariview-ios.git",
                 .upToNextMinor(from: oscaSafariViewVersion)),
    /* OSCAContact */
    packageLocal ? .package(path: "modules/OSCAContact") :
        .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscacontact-ios.git",
                 .upToNextMinor(from: oscaContactVersion)),
    /* OSCAContactUI */
    packageLocal ? .package(path: "modules/OSCAContactUI") :
        .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscacontactui-ios.git",
                 .upToNextMinor(from: oscaContactUIVersion)),
    /* OSCACoworking */
    packageLocal ? .package(path: "modules/OSCACoworking") :
        .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscacoworking-ios.git",
                 .upToNextMinor(from: oscaCoworkingVersion)),
    /* OSCACoworkingUI */
    packageLocal ? .package(path: "modules/OSCACoworkingUI") :
        .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscacoworkingui-ios.git",
                 .upToNextMinor(from: oscaCoworkingUIVersion)),
    /* OSCACulture */
    packageLocal ? .package(path: "modules/OSCACulture") :
        .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaculture-ios.git",
                 .upToNextMinor(from: oscaCultureVersion)),
    /* OSCACultureUI */
    packageLocal ? .package(path: "modules/OSCACultureUI") :
      .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscacultureui-ios.git",
               .upToNextMinor(from: oscaCultureUIVersion)),
    /* OSCADefect */
    packageLocal ? .package(path: "modules/OSCADefect") :
      .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscadefect-ios.git",
               .upToNextMinor(from: oscaDefectVersion)),
    /* OSCADefectUI */
    packageLocal ? .package(path: "modules/OSCADefectUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscadefectui-ios.git",
             .upToNextMinor(from: oscaDefectUIVersion)),
    /* OSCADistrict */
    districtPackageLocal ? .package(name: "OSCADistrict", path: "modules/OSCADistrict") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscadistrict-ios.git",
             .upToNextMinor(from: oscaDistrictVersion)),
    /* OSCAEnvironmentUI */
    /// use local package path
    environmentUIPackageLocal ? .package(name: "OSCAEnvironmentUI", path: "modules/OSCAEnvironmentUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaenvironment-ios.git",
             .upToNextMinor(from: oscaEnvironmentUIVersion)),
    /* OSCAEssentials */
    /// use local package path
    packageLocal ? .package(path: "modules/OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    /* OSCAEvents */
    packageLocal ? .package(path: "modules/OSCAEvents") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaevents-ios.git",
             .upToNextMinor(from: oscaEventsVersion)),
    /* OSCAEventsUI */
    packageLocal ? .package(path: "modules/OSCAEventsUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaeventsui-ios.git",
             .upToNextMinor(from: oscaEventsUIVersion)),
    /* OSCAJobs */
    packageLocal ? .package(path: "modules/OSCAJobs") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscajobs-ios.git",
             .upToNextMinor(from: oscaJobsVersion)),
    /* OSCAJobsUI */
    packageLocal ? .package(path: "modules/OSCAJobsUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscajobsui-ios.git",
             .upToNextMinor(from: oscaJobsUIVersion)),
    /* OSCAMap */
    packageLocal ? .package(path: "modules/OSCAMap") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscamap-ios.git",
             .upToNextMinor(from: oscaMapVersion)),
    /* OSCAMapUI */
    packageLocal ? .package(path: "modules/OSCAMapUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscamapui-ios.git",
             .upToNextMinor(from: oscaMapUIVersion)),
    /* OSCANetworkService */
    packageLocal ? .package(path: "modules/OSCANetworkService") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscanetworkservice-ios.git",
             .upToNextMinor(from: oscaNetworkServiceVersion)),
    /* OSCAPressReleases */
    packageLocal ? .package(path: "modules/OSCAPressReleases") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscapressreleases-ios.git",
             .upToNextMinor(from: oscaPressReleasesVersion)),
    /* OSCAPressReleasesUI */
    packageLocal ? .package(path: "modules/OSCAPressReleasesUI"):
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscapressreleasesui-ios.git",
             .upToNextMinor(from: oscaPressReleasesUIVersion)),
    /* OSCAPublicTransport */
    packageLocal ? .package(path: "modules/OSCAPublicTransport") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscapublictransport-ios.git",
             .upToNextMinor(from: oscaPublicTransportVersion)),
    /* OSCAPublicTransportUI */
    packageLocal ? .package(path: "modules/OSCAPublicTransportUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscapublictransportui-ios.git",
             .upToNextMinor(from: oscaPublicTransportUIVersion)),
    /* OSCATestCaseExtension */
    packageLocal ? .package(path: "modules/OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
    /* OSCAWaste */
    packageLocal ? .package(path: "modules/OSCAWaste") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscawaste-ios.git",
             .upToNextMinor(from: oscaWasteVersion)),
    /* OSCAWasteUI */
    packageLocal ? .package(path: "modules/OSCAWasteUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscawasteui-ios.git",
             .upToNextMinor(from: oscaWasteUIVersion)),
    /* OSCAWeather */
    packageLocal ? .package(path: "modules/OSCAWeather") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaweather-ios.git",
             .upToNextMinor(from: oscaWeatherVersion)),
    /* OSCAWeatherUI */
    packageLocal ? .package(path: "modules/OSCAWeatherUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaweatherui-ios.git",
             .upToNextMinor(from: oscaWeatherUIVersion)),
    /* OSCAMobility */
    packageLocal ? .package(path: "modules/OSCAMobilityMonitor") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscamobilitymonitor-ios.git",
             .upToNextMinor(from: oscaMobilityVersion)),
    /* OSCAMobilityUI */
    packageLocal ? .package(path: "modules/OSCAMobilityMonitorUI") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscamobilitymonitorui-ios.git",
             .upToNextMinor(from: oscaMobilityUIVersion)),
    /* SwiftSoup */
    .package(url: "https://github.com/scinfu/SwiftSoup.git",
             .upToNextMinor(from: swiftSoupVersion)),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.9.3")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCASolingen",
      dependencies: [
        /* OSCASafariView */
        .product(name: "OSCASafariView",
                 package: packageLocal ? "OSCASafariView" : "oscasafariview-ios"),
        /* OSCAContact */
        .product(name: "OSCAContact",
                 package: packageLocal ? "OSCAContact" : "oscacontact-ios"),
        /* OSCAContactUI */
        .product(name: "OSCAContactUI",
                 package: packageLocal ? "OSCAContactUI" : "oscacontactui-ios"),
        /* OSCACoworking */
        .product(name: "OSCACoworking",
                 package: packageLocal ? "OSCACoworking" : "oscacoworking-ios"),
        /* OSCACoworkingUI */
        .product(name: "OSCACoworkingUI",
                 package: packageLocal ? "OSCACoworkingUI" : "oscacoworkingui-ios"),
        /* OSCACulture */
        .product(name: "OSCACulture",
                 package: packageLocal ? "OSCACulture" : "oscaculture-ios"),
        /* OSCACultureUI */
        .product(name: "OSCACultureUI",
                 package: packageLocal ? "OSCACultureUI" : "oscacultureui-ios"),
        /* OSCADefect */
          .product(name: "OSCADefect",
                   package: packageLocal ? "OSCADefect" : "oscadefect-ios"),
        /* OSCADefectUI */
        .product(name: "OSCADefectUI",
                 package: packageLocal ? "OSCADefectUI" : "oscadefectui-ios"),
        /* OSCADistrict */
        .product(name: "OSCADistrict",
                package: districtPackageLocal ? "OSCADistrict" : "oscadistrict-ios"),
        /* OSCAEnvironmentUI */
        .product(name: "OSCAEnvironmentUI",
                package: environmentUIPackageLocal ? "OSCAEnvironmentUI" : "oscaenvironment-ios"),
        /* OSCAEssentials */
        .product(name: "OSCAEssentials",
                 package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
        /* OSCAEvents */
          .product(name: "OSCAEvents",
                   package: packageLocal ? "OSCAEvents" : "oscaevents-ios"),
        /* OSCAEventsUI */
        .product(name: "OSCAEventsUI",
                 package: packageLocal ? "OSCAEventsUI" : "oscaeventsui-ios"),
        /* OSCAJobs */
        .product(name: "OSCAJobs",
                 package: packageLocal ? "OSCAJobs" : "oscajobs-ios"),
        /* OSCAJobsUI */
        .product(name: "OSCAJobsUI",
                 package: packageLocal ? "OSCAJobsUI" : "oscajobsui-ios"),
        /* OSCAMap */
        .product(name: "OSCAMap",
                 package: packageLocal ? "OSCAMap" : "oscamap-ios"),
        /* OSCAMapUI */
        .product(name: "OSCAMapUI",
                 package: packageLocal ? "OSCAMapUI" : "oscamapui-ios"),
        /* OSCANetworkService */
        .product(name: "OSCANetworkService",
                 package: packageLocal ? "OSCANetworkService" : "oscanetworkservice-ios"),
        /* OSCAPressReleases */
        .product(name: "OSCAPressReleases",
                 package: packageLocal ? "OSCAPressReleases" : "oscapressreleases-ios"),
        /* OSCAPressReleasesUI */
        .product(name: "OSCAPressReleasesUI",
                 package: packageLocal ? "OSCAPressReleasesUI" : "oscapressreleasesui-ios"),
        /* OSCAPublicTransport */
        .product(name: "OSCAPublicTransport",
                 package: packageLocal ? "OSCAPublicTransport" : "oscapublictransport-ios"),
        /* OSCAPublicTransportUI */
        .product(name: "OSCAPublicTransportUI",
                 package: packageLocal ? "OSCAPublicTransportUI" : "oscapublictransportui-ios"),
        /* OSCAWaste */
          .product(name: "OSCAWaste",
                   package: packageLocal ? "OSCAWaste" : "oscawaste-ios"),
        /* OSCAWasteUI */
        .product(name: "OSCAWasteUI",
                 package: packageLocal ? "OSCAWasteUI" : "oscawasteui-ios"),
        /* OSCAWeather */
        .product(name: "OSCAWeather",
                 package: packageLocal ? "OSCAWeather" : "oscaweather-ios"),
        /* OSCAWeatherUI */
        .product(name: "OSCAWeatherUI",
                 package: packageLocal ? "OSCAWeatherUI" : "oscaweatherui-ios"),
        /* OSCAMobility */
        .product(name: "OSCAMobility",
                 package: packageLocal ? "OSCAMobilityMonitor" : "oscamobilitymonitor-ios"),
        /* OSCAMobilityUI */
        .product(name: "OSCAMobilityUI",
                 package: packageLocal ? "OSCAMobilityMonitorUI" : "oscamobilitymonitorui-ios"),
        /* SwiftSoup */
        .product(name: "SwiftSoup",
                 package: "SwiftSoup"),
        .product(name: "Sentry", package: "sentry-cocoa")
      ],
      path: "OSCASolingen/OSCASolingen",
      exclude:["Info.plist",
        "SupportingFiles"],
      resources: [.process("Resources")]),
    // test target
    .testTarget(
      name: "OSCASolingenTests",
      dependencies: ["OSCASolingen",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")
      ],
      path: "OSCASolingen/OSCASolingenTests",
      exclude:["Info.plist"],
      resources: [.process("Resources")])
  ],
  swiftLanguageVersions: [.v5]
)// end Package
