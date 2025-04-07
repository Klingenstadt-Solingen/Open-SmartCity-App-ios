//
//  AppDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 01.06.22.
//  Reviewed by Stephan Breidenbach on 13.06.2022
//  Reviewed by Stephan Breidenbach on 22.06.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import Combine
import DeviceKit
import OSCAEssentials
import OSCANetworkService
import OSCASafariView
import UIKit

/**
 The app `AppDI`'s root DI container is the factory that creates instances of objects with their dependencies.
 */
public final class AppDI {
  public struct Dependencies {
    public init(appConfiguration: OSCAAppConfig,
                devNetworkService: OSCANetworkService,
                productionNetworkService: OSCANetworkService,
                userDefaults: UserDefaults,
                deeplinkScheme: String,
                analyticsModule: OSCAAnalyticsModule? = nil) {
      self.appConfiguration = appConfiguration
      self.devNetworkService = devNetworkService
      self.productionNetworkService = productionNetworkService
      self.userDefaults = userDefaults
      self.deeplinkScheme = deeplinkScheme
      self.analyticsModule = analyticsModule
    } // end memberwise init

    var appConfiguration: OSCAAppConfig
    var devNetworkService: OSCANetworkService
    var productionNetworkService: OSCANetworkService
    var userDefaults: UserDefaults
    var deeplinkScheme: String
    var analyticsModule: OSCAAnalyticsModule?
  } // end struct AppDI.Dependencies

  let appConfiguration: OSCAAppConfig!

  private var bindings: Set<AnyCancellable> = []
  
  @LazyInjectedSafe(.by(type: OSCANetworkService.self),
                    container: DIContainer.container(for: .develop),
                    mode: .shared)
  var devNetworkServiceInjected: OSCANetworkService?
  
  let _devNetworkService: OSCANetworkService!
  var devNetworkService: OSCANetworkService {
    if let devNetworkService = _devNetworkService {
      return devNetworkService
    } else {
#warning("TODO: fatalError")
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    } // end if
  } // end var devNetworkService

  @LazyInjectedSafe(.by(type: OSCANetworkService.self),
                    container: DIContainer.container(for: .production),
                    mode: .shared)
  var productionNetworkServiceInjected: OSCANetworkService?
  let _productionNetworkService: OSCANetworkService!
  var productionNetworkService: OSCANetworkService {
    if let prodNetworkService = _productionNetworkService {
      return prodNetworkService
    } else {
#warning("TODO: fatalError")
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    } // end if
  } // end var productionNetworkService

  let _userDefaults: UserDefaults!
  var userDefaults: UserDefaults {
    if let userDefaults = _userDefaults {
      return userDefaults
    } else {
#warning("TODO: fatalError")
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    } // end if
  } // end var userDefaults

  var _coreModuleDI: OSCASolingenDI!
  var coreModuleDI: OSCASolingenDI {
    if let coreModuleDI = _coreModuleDI {
      return coreModuleDI
    } else {
#warning("TODO: fatalError")
      fatalError("construct `AppDI` with `AppDI.create()`!!")
    } // end if
  } // end var coreModuleDI

  let deeplinkScheme: String

  let analyticsModule: OSCAAnalyticsModule?
  var appFlowDI: AppDI.SolingenAppFlowDI?
  var webViewDI: AppDI.OSCASafariViewDI?
  var launchDI: AppDI.LaunchDI?
  var onBoardingDI: AppDI.OnboardingDI?
  var homeTabRootDI: AppDI.HomeTabRootDI?
  var cityDI: AppDI.CityDI?
  var settingsDI: AppDI.SettingsDI?
  var townhallDI: AppDI.TownhallDI?
  var serviceDI: AppDI.ServiceDI?
  /* Disabled module Corona
   var coronaDI: AppDI.OSCACoronaUIDI?
   */
  var pressReleasesDI: AppDI.OSCAPressReleasesUIDI?
  var contactDI: AppDI.OSCAContactUIDI?
  var weatherDI: AppDI.OSCAWeatherUIDI?
  var districtDI: AppDI.OSCADistrictDI?
  var eventsDI: AppDI.OSCAEventsUIDI?
  var mapDI: AppDI.OSCAMapUIDI?
  var defectDI: AppDI.OSCADefectUIDI?
  var coworkingDI: AppDI.OSCACoworkingUIDI?
  var publicTransportDI: AppDI.OSCAPublicTransportUIDI?
  var wasteDI: AppDI.OSCAWasteUIDI?
  var jobsDI: AppDI.OSCAJobsUIDI?
  var cultureDI: AppDI.OSCACultureUIDI?
  var mobilityDI: AppDI.OSCAMobilityUIDI?
  var appointmentsDI: AppDI.OSCAAppointmentsUIDI?
  var environmentDI: AppDI.OSCAEnvironmentDI?

  /**
   `UIWindow`is the backdrop for your app's user interface and the object that dispatches events to your views.

   creating `appWindow` which holds on the app's `UIWindow` instance
   */
  lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
  func getName() -> String {
    return "AppDI"
  } // end func getName

  private init(dependencies: AppDI.Dependencies) {
    appConfiguration = dependencies.appConfiguration
    _devNetworkService = dependencies.devNetworkService
    _productionNetworkService = dependencies.productionNetworkService
    _userDefaults = dependencies.userDefaults
    deeplinkScheme = dependencies.deeplinkScheme
    analyticsModule = dependencies.analyticsModule
  } // end public init with dependencies

  /// `static` create method for the application's `Dependency injection container` class
  /// * application's configuration
  /// * application's `UserDefaults`
  /// * application's `NetworkService`development
  /// * application's `NetworkService` production
  /// * application's `Deeplink`scheme
  /// - parameter appConfig: `OSCAAppConfig` conforming application configuration
  public static func create(appConfig: OSCAAppConfig) throws -> AppDI {
    // register AppDI dependencies
    try AppDI.registerDI()
    makeOSCAEssentialsModule()
    let appConfiguration = appConfig
    let userDefaults = AppDI.makeUserDefaults()
    let devNetworkService = AppDI.makeDevNetworkService(from: appConfiguration, with: userDefaults)
    let productionNetworkService = AppDI.makeProductionNetworkService(from: appConfiguration, with: userDefaults)
    #if DEBUG
    print("DEV endpoint: \(devNetworkService.config.baseURL)")
    print("PROD endpoint: \(productionNetworkService.config.baseURL)")
    #endif
    let appDeeplinkScheme = appConfiguration.deeplinkScheme
    
    let dependencies = AppDI.Dependencies(appConfiguration: appConfiguration,
                                          devNetworkService: devNetworkService,
                                          productionNetworkService: productionNetworkService,
                                          userDefaults: userDefaults,
                                          deeplinkScheme: appDeeplinkScheme
    )
    let appDI: AppDI = AppDI(dependencies: dependencies)
    let coreModuleDIDependencoies = AppDI.OSCASolingenDI.Dependencies(appDI: appDI, deeplinkScheme: appDI.deeplinkScheme)
    let coreModuleDI = AppDI.OSCASolingenDI(dependencies: coreModuleDIDependencoies)
    appDI._coreModuleDI = coreModuleDI
    return appDI
  } // end public static func create with dependencies

  public static func create(with dependencies: AppDI.Dependencies) -> AppDI {
    let appDI = AppDI(dependencies: dependencies)
    let coreModuleDIDependencies = AppDI.OSCASolingenDI.Dependencies(appDI: appDI,
                                                                     deeplinkScheme: appDI.deeplinkScheme)
    let coreModuleDI = AppDI.OSCASolingenDI(dependencies: coreModuleDIDependencies)
    appDI._coreModuleDI = coreModuleDI
    return appDI
  } // end public static func create with dependencies
} // final class AppDI

// MARK: - Essentials

#warning("Check for OSCAEssentials module creation place!")
extension AppDI {
  private static func makeOSCAEssentialsModule() {
    _ = OSCAEssentials()
  }
} // end extension final class AppDI

// MARK: - network services

extension AppDI {
  private static func makeDevNetworkService(from appConfiguration: OSCAAppConfig, with userDefaults: UserDefaults) -> OSCANetworkService {
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": appConfiguration.parseAPIKeyDev,
      "X-PARSE-APPLICATION-ID": appConfiguration.parseApplicationIDDev/*,
      "X-Parse-Master-Key": appConfiguration.parseMasterKeyDev*/
    ] // end headers
    let baseURL: URL? = URL(string: appConfiguration.parseAPIBaseURLDev)
    guard let baseURL = baseURL else {
      fatalError("Dev Parse API Root URL is not well formed for this environment")
    } // end guard
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    ) // end let config
    let dependencies = OSCANetworkServiceDependencies(config: config,
                                                      userDefaults: userDefaults)
    let devNetworkService = OSCANetworkService.create(with: dependencies)
    return devNetworkService
  } // end private func makeDevNetworkService()

  private static func makeProductionNetworkService(from appConfiguration: OSCAAppConfig, with userDefaults: UserDefaults) -> OSCANetworkService {
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": appConfiguration.parseAPIKey,
      "X-PARSE-APPLICATION-ID": appConfiguration.parseApplicationID /*,
      "X-Parse-Master-Key": appConfiguration.parseMasterKey*/
    ] // end headers
    let baseURL: URL? = URL(string: appConfiguration.parseAPIBaseURL)
    guard let baseURL = baseURL else {
      fatalError("Parse API Root URL is not well formed for this environment")
    } // end guard
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    ) // end let config
    let dependencies = OSCANetworkServiceDependencies(config: config,
                                                      userDefaults: userDefaults)
    let productionNetworkService = OSCANetworkService.create(with: dependencies)
    return productionNetworkService
  } // end private func makeProductionNetworkService
} // end extension final class AppDI

// MARK: - UserDefaults

extension AppDI {
  private static func makeUserDefaults() -> UserDefaults {
    #warning("TODO: Check for UserDefaults implementation!!!")
    return UserDefaults.standard
  } // end var userDefaults
} // end extension final class AppDI

// MARK: - DI Core Module OSCASolingen

extension AppDI {
  /// make core module `OSCASolingen` `DI container`
  func makeOSCASolingenDI() -> AppDI.OSCASolingenDI {
    return coreModuleDI
  } // end func makeOSCASolingenDI
} // end extension final class AppDI

// MARK: - DI Solingen App Flow

extension AppDI {
  /// singleton app flow DI
  func makeSolingenAppFlowDI() -> AppDI.SolingenAppFlowDI {
    if let solingenAppFlowDI = appFlowDI {
      return solingenAppFlowDI
    } else {
      let dependencies = AppDI.SolingenAppFlowDI.Dependencies(appDI: self)
      let solingenAppFlowDI = AppDI.SolingenAppFlowDI(dependencies: dependencies)
      appFlowDI = solingenAppFlowDI
      return solingenAppFlowDI
    } // end if
  } // end func makeSolingenAppFlowDI
} // end extension AppDI

// MARK: - WebView scene DI container

extension AppDI {
  /// make web view scene singleton `DI container`
  func makeSafariViewDI() -> AppDI.OSCASafariViewDI {
    if let webViewDI = webViewDI {
      return webViewDI
    } else {
      let di = AppDI.OSCASafariViewDI()
      webViewDI = di
      return di
    } // end
  } // end func makeSafariViewDI
} // end extension final class AppDI

// MARK: - Launch scene DI container

extension AppDI {
  /// make launch scene singleton `DI container`
  func makeLaunchDI(firstStartDeeplinkURL: URL?,
                    presentOnboarding: @escaping () -> Void,
                    presentMain: @escaping (URL?) -> Void,
                    presentLogin: @escaping () -> Void,
                    appFlow: SolingenAppFlow) -> AppDI.LaunchDI {
    if let launchDI = launchDI {
      return launchDI
    } else {
      let dependencies = AppDI.LaunchDI.Dependencies(appDI: self,
                                                     firstStartDeeplinkURL: firstStartDeeplinkURL,
                                                     deeplinkScheme: deeplinkScheme,
                                                     presentOnboarding: presentOnboarding,
                                                     presentMain: presentMain,
                                                     presentLogin: presentLogin,
                                                     appFlow: appFlow)
      let di = AppDI.LaunchDI(dependencies: dependencies)
      launchDI = di
      return di
    } // end if
  } // end func makeOnboardingDI
} // end extension final class AppDI

// MARK: - Onboarding scene DI container

extension AppDI {
  /// make onboarding scene singleton `DI container`
  func makeOnboardingDI() -> AppDI.OnboardingDI {
    if let onBoardingDI = onBoardingDI {
      return onBoardingDI
    } else {
      let dependencies = AppDI.OnboardingDI.Dependencies(appDI: self,
                                                         deeplinkScheme: deeplinkScheme)
      let di = AppDI.OnboardingDI(dependencies: dependencies)
      onBoardingDI = di
      return di
    } // end if
  } // end func makeOnboardingDI
} // end extension final class AppDI

// MARK: - Home tab root scene DI container

extension AppDI {
  /// make home tab root scene singleton `DI container`
  func makeHomeTabRootDI(onDismissed: (() -> Void)? = nil) -> AppDI.HomeTabRootDI {
    if let homeTabRootDI = homeTabRootDI {
      return homeTabRootDI
    } else {
      let dependencies = AppDI.HomeTabRootDI.Dependencies(appDI: self,
                                                          deeplinkScheme: deeplinkScheme,
                                                          onDismissed: onDismissed)
      let di = AppDI.HomeTabRootDI(dependencies: dependencies)
      homeTabRootDI = di
      return di
    } // end if
  } // end func makeHomeTabRootDI
} // end extension final class AppDI

// MARK: - city view scene DI container

extension AppDI {
  /// make City Home scene singleton `DI container`
  func makeCityDI() -> AppDI.CityDI {
    if let cityDI = cityDI {
      return cityDI
    } else {
      if let homeTabRootController = self.makeHomeTabRootDI().homeTabRootCoordinator?.homeTabRootViewController {
        let cityViewDIDependencies = AppDI.CityDI.Dependencies(appDI: self,
                                                               homeTabRootController: homeTabRootController,
                                                               deeplinkScheme: deeplinkScheme)
        let di = AppDI.CityDI(dependencies: cityViewDIDependencies)
        cityDI = di
        return di
      } else {
        #warning("TODO dependency injection")
        fatalError("There is no bottom tab bar coordinator found!")
      }// end if
    } // end if
  } // end func make CityDI
} // end extension final class AppDI

// MARK: - settings view scene DI container

extension AppDI {
  /// make settings scene singleton `DI container`
  func makeSettingsDI() -> AppDI.SettingsDI {
    if let settingsDI = settingsDI {
      return settingsDI
    } else {
      let settingsViewDIDependencies = AppDI.SettingsDI.Dependencies(appDI: self,
                                                                     deeplinkScheme: deeplinkScheme)
      let di = AppDI.SettingsDI(dependencies: settingsViewDIDependencies)
      settingsDI = di
      return di
    } // end if
  } // end func makeSettingsDI
} // end extension final class AppDI

// MARK: - townhall view scene DI container

extension AppDI {
  /// make townhall scene singleton `DI container`
  func makeTownhallDI() -> AppDI.TownhallDI {
    if let townhallDI = townhallDI {
      return townhallDI
    } else {
      let townhallDIDependencies = AppDI.TownhallDI.Dependencies(appDI: self,
                                                                 deeplinkScheme: deeplinkScheme)
      let di = AppDI.TownhallDI(dependencies: townhallDIDependencies)
      townhallDI = di
      return di
    } // end if
  } // end func makeTownhallDI
} // end extension final class AppDI

// MARK: - service view scene DI container

extension AppDI {
  /// make service scene singleton `DI container`
  func makeServiceDI() -> AppDI.ServiceDI {
    if let serviceDI = serviceDI {
      return serviceDI
    } else {
      let serviceDIDependencies = AppDI.ServiceDI.Dependencies(appDI: self,
                                                               deeplinkScheme: deeplinkScheme)
      let di = AppDI.ServiceDI(dependencies: serviceDIDependencies)
      serviceDI = di
      return di
    } // end if
  } // end func make ServiceDI
} // end extension final class AppDI

/* Disabled module Corona
// MARK: - DI feature module OSCACoronaUI
extension AppDI {
  /// make corona scene singleton `DI container`
  func makeOSCACoronaUIDI() -> AppDI.OSCACoronaUIDI {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let coronaDI = coronaDI {
      return coronaDI
    } else {
      let webViewModule = makeSafariViewDI()
        .makeOSCASafariViewModule()
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCACoronaUIDI.Dependencies(webViewModule: webViewModule,
                                                           networkService: networkService,
                                                           userDefaults: userDefaults,
                                                           deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCACoronaUIDI(dependencies: dependencies)
      coronaDI = di
      return di
    } // end if
  } // end func makeOSCACoronaUIDI
} // end extension final class AppDI
 */

// MARK: - DI feature module OSCAPressReleasesUI

extension AppDI {
  /// make press releases scene singleton `DI container`
  func makeOSCAPressReleasesUIDI() -> AppDI.OSCAPressReleasesUIDI {
    if let pressReleasesDI = pressReleasesDI {
      return pressReleasesDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAPressReleasesUIDI.Dependencies(networkService: networkService,
                                                                  userDefaults: userDefaults,
                                                                  deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAPressReleasesUIDI(dependencies: dependencies)
      pressReleasesDI = di
      return di
    } // end if
  } // end func makeOSCAPressReleasesUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAContactUI

extension AppDI {
  /// make contact scene singleton `DI container`
  func makeOSCAContactUIDI() -> AppDI.OSCAContactUIDI {
    if let contactDI = contactDI {
      return contactDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAContactUIDI.Dependencies(networkService: networkService,
                                                            userDefaults: userDefaults,
                                                            deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAContactUIDI(dependencies: dependencies)
      contactDI = di
      return di
    } // end if
  } // end func makeOSCAContactUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAWeatherUI

extension AppDI {
  /// make weather scene singleton `DI container`
  func makeOSCAWeatherUIDI() -> AppDI.OSCAWeatherUIDI {
    if let weatherDI = weatherDI {
      return weatherDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAWeatherUIDI.Dependencies(networkService: networkService,
                                                            userDefaults: userDefaults,
                                                            deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAWeatherUIDI(dependencies: dependencies)
      weatherDI = di
      return di
    } // end if
  } // end func makeOSCAWeatherUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAEventsUI

extension AppDI {
  /// make events scene singleton `DI container`
  func makeOSCAEventsUIDI() -> AppDI.OSCAEventsUIDI {
    if let eventsDI = eventsDI {
      return eventsDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAEventsUIDI.Dependencies(networkService: networkService,
                                                           userDefaults: userDefaults,
                                                           deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAEventsUIDI(dependencies: dependencies)
      eventsDI = di
      return di
    } // end if
  } // end func makeOSCAEventsUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAMapUI

extension AppDI {
  /// make map scene singleton `DI container`
  func makeOSCAMapUIDI() -> AppDI.OSCAMapUIDI {
    if let mapDI = mapDI {
      return mapDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAMapUIDI.Dependencies(networkService: networkService,
                                                        userDefaults: userDefaults,
                                                        deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAMapUIDI(dependencies: dependencies)
      mapDI = di
      return di
    } // end if
  } // end func makeOSCAMapUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCADefectUI

extension AppDI {
  /// make defect scene singleton `DI container`
  func makeOSCADefectUIDI() -> AppDI.OSCADefectUIDI {
    if let defectDI = defectDI {
      return defectDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCADefectUIDI.Dependencies(networkService: networkService,
                                                           userDefaults: userDefaults,
                                                           deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCADefectUIDI(dependencies: dependencies)
      defectDI = di
      return di
    } // end if
  } // end func makeOSCADefectUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCACoworkingUI

extension AppDI {
  /// make coworking scene singleton `DI container`
  func makeOSCACoworkingUIDI() -> AppDI.OSCACoworkingUIDI {
    if let coworkingDI = self.coworkingDI {
      return coworkingDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCACoworkingUIDI.Dependencies(networkService: networkService,
                                                           userDefaults: userDefaults,
                                                           deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCACoworkingUIDI(dependencies: dependencies)
      self.coworkingDI = di
      return di
    } // end if
  } // end func makeOSCACoworkingUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAPublicTransportUI

extension AppDI {
  /// make public transport scene singleton `DI container`
  func makeOSCAPublicTransportUIDI() -> AppDI.OSCAPublicTransportUIDI {
    if let publicTransportDI = publicTransportDI {
      return publicTransportDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAPublicTransportUIDI.Dependencies(networkService: networkService,
                                                                    userDefaults: userDefaults,
                                                                    deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAPublicTransportUIDI(dependencies: dependencies)
      publicTransportDI = di
      return di
    } // end if
  } // end func make OSCAPublicTransportUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAWasteUI

extension AppDI {
  /// make waste scene singleton `DI container`
  func makeOSCAWasteUIDI() -> AppDI.OSCAWasteUIDI {
    if let wasteDI = wasteDI {
      return wasteDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let webViewModule = makeSafariViewDI()
        .makeOSCASafariViewModule()
      let dependencies = AppDI.OSCAWasteUIDI.Dependencies(webViewModule: webViewModule,
                                                          networkService: networkService,
                                                          userDefaults: userDefaults,
                                                          deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAWasteUIDI(dependencies: dependencies)
      wasteDI = di
      return di
    } // end if
  } // end func makeOSCAWeateUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAJobsUI

extension AppDI {
  /// make jobs scene singleton `DI container`
  func makeOSCAJobsUIDI() -> AppDI.OSCAJobsUIDI {
    if let jobsDI = jobsDI {
      return jobsDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let webModule = makeSafariViewDI()
        .makeOSCASafariViewModule()
      let dependencies = AppDI.OSCAJobsUIDI.Dependencies(webViewModule: webModule,
                                                         networkService: networkService,
                                                         userDefaults: userDefaults,
                                                         deeplinkScheme: deeplinkScheme)
      let di = AppDI.OSCAJobsUIDI(dependencies: dependencies)
      jobsDI = di
      return di
    } // end if
  } // end func makeOSCAJobsUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCACultureUI

extension AppDI {
  /// make culture scene singleton `DI container`
  func makeOSCACultureUIDI() -> AppDI.OSCACultureUIDI {
    if let cultureDI = cultureDI {
      return cultureDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCACultureUIDI.Dependencies(appDI: self,
                                                            networkService: networkService,
                                                            userDefaults: userDefaults,
                                                            deeplinkScheme: deeplinkScheme)

      let di = AppDI.OSCACultureUIDI(dependencies: dependencies)
      cultureDI = di
      return di
    } // end if
  } // end func makeOSCACultureUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAMobilityUI

extension AppDI {
  /// make culture scene singleton `DI container`
  func makeOSCAMobilityUIDI() -> AppDI.OSCAMobilityUIDI {
    if let mobilityDI = mobilityDI {
      return mobilityDI
    } else {
#if DEBUG
      let networkService = devNetworkService
#else
      let networkService = productionNetworkService
#endif
      let dependencies = AppDI.OSCAMobilityUIDI.Dependencies(networkService: networkService,
                                                             userDefaults: userDefaults,
                                                             deeplinkScheme: deeplinkScheme)

      let di = AppDI.OSCAMobilityUIDI(dependencies: dependencies)
      mobilityDI = di
      return di
    } // end if
  } // end func makeOSCACultureUIDI
} // end extension final class AppDI

// MARK: - DI feature module OSCAAppointments
extension AppDI {
  /// make appointments scene singleton `DI container`
  func makeOSCAAppointmentsUIDI() -> AppDI.OSCAAppointmentsUIDI {
    if let appointmentsDI = self.appointmentsDI {
      return appointmentsDI
    } else {
#if DEBUG
      let networkService = self.devNetworkService
#else
      let networkService = self.productionNetworkService
#endif
      let webModule = makeSafariViewDI().makeOSCASafariViewModule()
      let dependencies = AppDI.OSCAAppointmentsUIDI.Dependencies(
        networkService: networkService,
        userDefaults: self.userDefaults,
        webViewModule: webModule,
        deeplinkScheme: self.deeplinkScheme)
      let di = AppDI.OSCAAppointmentsUIDI(dependencies: dependencies)
      self.appointmentsDI = di
      return di
    }
  }
}

extension AppDI {
    func makeOSCAEnvironmentDI() -> AppDI.OSCAEnvironmentDI {
        if let environmentDI = environmentDI {
            return environmentDI
        } else {
            let dependencies = AppDI.OSCAEnvironmentDI.Dependencies(userDefaults: userDefaults, deeplinkScheme: deeplinkScheme)
            let di = AppDI.OSCAEnvironmentDI(dependencies: dependencies)
            environmentDI = di
            return di
        }
    }
    /// make weather scene singleton `DI container`
    func makeOSCADistrictDI() -> AppDI.OSCADistrictDI {
        if let districtDI = districtDI {
            return districtDI
        } else {
            let dependencies = AppDI.OSCADistrictDI.Dependencies(userDefaults: userDefaults,
                                                                      deeplinkScheme: deeplinkScheme)
            let di = AppDI.OSCADistrictDI(dependencies: dependencies)
            districtDI = di
            return di
        } // end if
    }
}


