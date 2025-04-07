//
//  OSCASolingen.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.08.22.
//

import OSCAEssentials
import OSCANetworkService
import UIKit
import OSCAWeather


/// OSCASolingen core module
public struct OSCASolingen: OSCAModule {
  /// module DI container
  var moduleDI: OSCASolingen.DIContainer!
  
  /// module app DI container
  var moduleAppDI: AppDI!
  
  /// version of the module
  public var version: String = "3.2.0"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.solingen.core"
  
  
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  public private(set) var userDefaults: UserDefaults!
  
  ///
  private var devNetworkService: OSCANetworkService
  
  private var productionNetworkService: OSCANetworkService
  
  /**
   create module and inject module dependencies
   
   ** This is the only way to initialize the module!!! **
   - Parameter moduleDependencies: module dependencies
   ```
   call: OSCASolingen.create(with moduleDependencies)
   ```
   */
  public static func create(with moduleDependencies: OSCASolingen.Dependencies) -> OSCASolingen {
    let devNetworkService = moduleDependencies
      .appDI
      .devNetworkService
    let productionNetworkService = moduleDependencies
      .appDI
      .productionNetworkService
    let userDefaults = moduleDependencies
      .appDI
      .userDefaults
    let appDI = moduleDependencies
      .appDI
    var module: Self = Self.init(devNetworkService: devNetworkService,
                                 productionNetworkService: productionNetworkService,
                                 userDefaults: userDefaults)
    
    // module DI container
    module.moduleDI     = OSCASolingen.DIContainer(dependencies: moduleDependencies)
    
    // module app DI
    module.moduleAppDI  = appDI
    
    return module
  }// end public static func create
  
  /// initializes the contact module
  ///  - Parameter networkService: Your configured network service
  ///  - Parameter userDefaults: user defaults 
  private init(devNetworkService: OSCANetworkService,
               productionNetworkService: OSCANetworkService,
               userDefaults: UserDefaults) {
    self.devNetworkService = devNetworkService
    self.productionNetworkService = productionNetworkService
    self.userDefaults = userDefaults
    var bundle: Bundle?
#if SWIFT_PACKAGE
    bundle = Bundle.module
#else
    bundle = Bundle(identifier: self.bundlePrefix)
#endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  }// end public init with network service
  
  private init(appDI: AppDI) {
    self.devNetworkService = appDI.devNetworkService
    self.productionNetworkService = appDI.productionNetworkService
    self.userDefaults = appDI.userDefaults
    var bundle: Bundle?
#if SWIFT_PACKAGE
    bundle = Bundle.module
#else
    bundle = Bundle(identifier: self.bundlePrefix)
#endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    OSCASolingen.bundle = bundle
  }// end private init with app di
    
  public struct Dependencies {
    public init(appDI: AppDI,
                analyticsModule: OSCAAnalyticsModule? = nil) {
      self.appDI = appDI
      self.analyticsModule = analyticsModule
    }// end public init
    
    public let appDI: AppDI
    public let analyticsModule: OSCAAnalyticsModule?
  }// end public struct Dependencies

  /// public getter of `SolingenAppFlow`
  /// - Parameter window: main scene window
  /// - Parameter onDismissed: closure
  /// - Returns : `SolingenAppFlow`
  public func getSolingenAppFlow(window: UIWindow,
                                 onDismissed: (() -> Void)? ) -> SolingenAppFlow {
    let flow = self.moduleAppDI
     .makeSolingenAppFlowDI()
     .makeSolingenAppFlow(window: window,
                          onDismissed: onDismissed)
    return flow
  }// end public func getSolingenAppFlow
  
  
  /// public getter of `HomeTabRootCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns : `HomeTabRootCoordinator`
  public func getHomeTabRootCoordinator(window: UIWindow,
                                        onDismissed: (() -> Void)?) -> HomeTabRootCoordinator {
    let flow = self.moduleAppDI
      .makeHomeTabRootDI(onDismissed: onDismissed)
      .makeHomeTabRootCoordinator(window: window)
    return flow
  }// end public func getHomeTabRootCoordinator
  
  public func getHomeTabRootDeeplinkHandeble(window: UIWindow,
                                             onDismissed: (() -> Void)?) -> OSCADeeplinkHandeble {
    let flow = getHomeTabRootCoordinator(window: window,
                                         onDismissed: onDismissed)
    return flow as OSCADeeplinkHandeble
  }// end public func getCityDeeplinkHandeble

  /// public getter of `LaunchFlow`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getLaunchCoordinator(router: Router,
                                   appFlow: SolingenAppFlow,
                                   firstStartDeeplinkURL: URL?,
                                   presentOnboarding: @escaping () -> Void,
                                   presentMain: @escaping (URL?) -> Void,
                                   presentLogin: @escaping () -> Void ) -> Coordinator {
    let flow = self.moduleAppDI
      .makeLaunchDI( firstStartDeeplinkURL: firstStartDeeplinkURL,
                     presentOnboarding: presentOnboarding,
                     presentMain: presentMain,
                     presentLogin: presentLogin,
                     appFlow: appFlow)
      .makeLaunchFlow(router: router)
    return flow
  }// end public func getOnboardingCoordinator

  /// public getter of `OnboardingFlow`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOnboardingCoordinator(router: Router,
                                       onboardingCompletion: @escaping () -> Void) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOnboardingDI()
      .makeOnboardingFlowCoordinator(router: router,
                                     onboardingCompletion: onboardingCompletion)
    return flow
  }// end public func getOnboardingCoordinator

  /// public getter of `CityFlow`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getCityCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeCityDI()
      .makeCityFlowCoordinator(router: router)
    return flow
  }// end public func getCityCoordinator
  
  public func getCityDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getCityCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getCityDeeplinkHandeble

  /// public getter of `TownhallFlow`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getTownhallCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeTownhallDI()
      .makeTownhallFlowCoordinator(router: router)
    return flow
  }// end public func getTownhallCoordinator
  
  public func getTownhallDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getTownhallCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getTownhallDeeplinkHandeble

  /// public getter of `ServiceViewFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getServiceCoordinator(router: Router) -> Coordinator {

    let flow = self.moduleAppDI
      .makeServiceDI()
      .makeServiceFlowCoordinator(router: router)
    return flow
  }// end public func getServiceCoordinator
  
  public func getServiceDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getServiceCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getServiceDeeplinkHandeble
    
  /// public getter of `SettingsFlow`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getSettingsCoordinator(router: Router) -> Coordinator {

    let flow = self.moduleAppDI
      .makeSettingsDI()
      .makeSettingsFlowCoordinator(router: router)
    return flow
  }// end public func getSettingsCoordinator
  
  public func getSettingsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getSettingsCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getSettingsDeeplinkHandeble

  /// public getter of `OSCAContactFormFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAContactCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAContactUIDI()
      .makeOSCAContactFormFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAContactCoordinator
  
  public func getOSCAContactDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAContactCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAContactDeeplinkHandeble

  /// public getter of `OSCAPressReleasesFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAPressReleasesCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAPressReleasesUIDI()
      .makeOSCAPressReleasesFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAPressReleasesCoordinator
  
  public func getOSCAPressReleasesDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAPressReleasesCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAPressReleasesCoordinator

  /// public getter of `OSCAWeatherFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAWeatherCoordinator(router: Router,
                                        selectedWeatherObservedId: String) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAWeatherUIDI()
      .makeOSCAWeatherFlowCoordinator(router: router,
                                      selectedWeatherObservedId: selectedWeatherObservedId)
    return flow
  }// end public func getOSCAWeatherCoordinator
  
  /// public getter of `OSCAWeatherFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAWeatherCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAWeatherUIDI()
      .makeOSCAWeatherFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAWeatherCoordinator
  
  public func getOSCAWeatherDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAWeatherCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAWeatherDeeplinkHandeble

  /// public getter of `OSCAEventsFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAEventsCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAEventsUIDI()
      .makeOSCAEventsFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAEventsCoordinator
  
  public func getOSCAEventsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAEventsCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAEventsDeeplinkHandeble

  /// public getter of `OSCAMapFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAMapCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAMapUIDI()
      .makeOSCAMapFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAMapCoordinator
  
  public func getOSCAMapDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAMapCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAMapDeeplinkHandeble

  /// public getter of `OSCADefectFormFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCADefectCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCADefectUIDI()
      .makeOSCADefectFormFlowCoordinator(router: router)
    return flow
  }// end public func getOSCADefectCoordinator
  
  public func getOSCADefectDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCADefectCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCADefectDeeplinkHandeble

  /// public getter of `OSCACoworkingFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCACoworkingCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCACoworkingUIDI()
      .makeOSCACoworkingFlowCoordinator(router: router)
    return flow
  }// end public func getOSCACoworkingCoordinator
  
  public func getOSCACoworkingDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCACoworkingCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCACoworkingDeeplinkHandeble

  /// public getter of `OSCAPublicTransportFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAPublicTransportCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAPublicTransportUIDI()
      .makeOSCAPublicTransportFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAPublicTransportCoordinator
  
  public func getOSCAPublicTransportDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAPublicTransportCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCACoronaDeeplinkHandeble

  /// public getter of `OSCAMobilityFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAMobilityCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAMobilityUIDI()
      .makeOSCAMobilityFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAWasteCoordinator
  
  public func getOSCAMobilityDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAMobilityCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAMobilityDeeplinkHandeble

  /// public getter of `OSCAWasteFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAWasteCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAWasteUIDI()
      .makeOSCAWasteFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAWasteCoordinator
  
  /// public getter of `OSCAPublicTransportFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAWasteSetupCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAWasteUIDI()
      .makeOSCAWasteSetupFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAWasteSetupCoordinator
  
  public func getOSCAWasteDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAWasteCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAWasteDeeplinkHandeble

  /// public getter of `OSCAJobsFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAJobsCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAJobsUIDI()
      .makeOSCAJobsFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAJobsCoordinator
  
  public func getOSCAJobsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCAJobsCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCAJobsDeeplinkHandeble
}// end extension public struct OSCASolingen

/* Disabled module Corona
// MARK: - public interface: Corona Flow
extension OSCASolingen {
  /// public getter of `OSCACoronaFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCACoronaCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = self.moduleAppDI
      .makeOSCACoronaUIDI()
      .makeOSCACoronaFlowCoordinator(router: router)
    return flow
  }// end public func getOSCACoronaCoordinator
  
  public func getOSCACoronaDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = getOSCACoronaCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCACoronaDeeplinkHandeble
}// end extension public struct OSCASolingen
 */

// MARK: - public interface: Culture Flow
extension OSCASolingen {
  /// public getter of `BeaconSearchFlow`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getBeaconSearchFlow(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCACultureUIDI()
      .makeBeaconSearchFlow(router: router)
    return flow
  }// end public func getBeaconSearchFlow
  
  public func getBeaconSearchDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getBeaconSearchFlow(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getBeaconSearchDeeplinkHandeble
}// end extension public struct OSCASolingen

// MARK: - public interface: Appointments Flow
extension OSCASolingen {
  /// public getter of `OSCAAppointmentsFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAAppointmentsCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCAAppointmentsUIDI()
      .makeOSCAAppointmentsFlowCoordinator(router: router)
    return flow
  }
  
  public func getOSCAAppointmentsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = self.getOSCAAppointmentsCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }
}

extension OSCASolingen {
  /// public getter of `OSCADistrictFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCADistrictCoordinator(router: Router) -> Coordinator {
    let flow = self.moduleAppDI
      .makeOSCADistrictDI()
      .makeOSCADistrictFlowCoordinator(router: router)
    return flow
  }// end public func getOSCADistrictCoordinator
  
  public func getOSCADistrictDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = getOSCADistrictCoordinator(router: router)
    return flow as! OSCADeeplinkHandeble
  }// end public func getOSCADistrictDeeplinkHandeble
}// end extension public struct OSCASolingen
