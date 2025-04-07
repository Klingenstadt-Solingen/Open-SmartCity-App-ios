//
//  AppDI+OSCAMobilityUIDI.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 05.10.22.
//

import OSCAEssentials
import OSCAMobility
import OSCAMobilityUI
import OSCANetworkService
import OSCAWeather
import UIKit

extension AppDI {
  final class OSCAMobilityUIDI {
    /**
     `OSCAMobilityUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults: UserDefaults
      let deeplinkScheme: String
    } // end struct Dependencies
    
    private let dependencies: Dependencies
    
    var MobilityFlow: OSCAMobilityFlowCoordinator?
    var dataModule: OSCAMobility?
    var weatherModule: OSCAWeather?
    
    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    // MARK: - Feature Module dependencies
    
    func makeOSCAMobilityDependencies() -> OSCAMobility.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
        let defaultLocation = AppDI.Environment.defaultLocation
      let dataModuleDependencies: OSCAMobility.Dependencies = OSCAMobility.Dependencies(networkService: dependencies.networkService, userDefaults: dependencies.userDefaults, defaultLocation: defaultLocation)
      return dataModuleDependencies
    } // end func makeOSCAMobilityDependencies
    
    func makeOSCAWeatherDependencies() -> OSCAWeatherDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAWeatherDependencies = OSCAWeatherDependencies(networkService: dependencies.networkService, userDefaults: dependencies.userDefaults)
      return dataModuleDependencies
    } // end func makeOSCAWeatherDependencies
    
    // MARK: - Feature Module
    
    /// singleton data module
    func makeOSCAMobilityModule() -> OSCAMobility {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let MobilityModule = dataModule {
        return MobilityModule
      } else {
        let MobilityModule = OSCAMobility.create(with: makeOSCAMobilityDependencies())
        dataModule = MobilityModule
        return MobilityModule
      } // end if
    } // end func makeOSCAMobility
    
    /// singleton data module
    func makeOSCAWeatherModule() -> OSCAWeather {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let weatherModule = weatherModule {
        return weatherModule
      } else {
        let weatherModule = OSCAWeather.create(with: makeOSCAWeatherDependencies())
        self.weatherModule = weatherModule
        return weatherModule
      } // end if
    } // end func makeOSCAMobility
    
    // MARK: - Feature UI Module shadow settings
    
    func makeOSCAMobilityUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.2,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    
    func makeOSCAMobilityUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    } // end func make OSCAColorSettings for press releases ui
    
    // MARK: - Feature UI Module Type face settings
    
    func makeOSCAMobilityUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    } // end func make OSCAFontSettings for press releases ui
    
    // MARK: - Feature UI Module Config
    
    func makeOSCAMobilityUIConfig() -> OSCAMobilityUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAMobilityUIConfig(title: "OSCAMobilityUI",
                                  shadowSettings: makeOSCAMobilityUIShadowSettings(),
                                  cornerRadius: 10.0,
                                  fontConfig: makeOSCAMobilityUIFontSettings(),
                                  colorConfig: makeOSCAMobilityUIColorSettings())
    } // end func make OSCAMobilityUIConfig
    
    // MARK: - Feature UI Module dependencies
    
    func makeOSCAMobilityUIModuleDependencies() -> OSCAMobilityUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAMobilityUIDependencies(dataModule: makeOSCAMobilityModule(),
                                        weatherModule: makeOSCAWeatherModule(),
                                        moduleConfig: makeOSCAMobilityUIConfig())
    } // end func make OSCAMobilityUI dependencies
    
    // MARK: - Feature UI Module
    
    func makeOSCAMobilityUIModule() -> OSCAMobilityUI {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      return OSCAMobilityUI.create(with: makeOSCAMobilityUIModuleDependencies())
    } // end func makePressReleaseModule
  } // end final class OSCAMobilityUIDI
} // end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators

extension AppDI.OSCAMobilityUIDI {
  /// singleton `Coordinator`
  func makeOSCAMobilityFlowCoordinator(router: Router) -> OSCAMobilityFlowCoordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let MobilityFlow = MobilityFlow {
      return MobilityFlow
    } else {
      let flow = makeOSCAMobilityUIModule()
        .getMobilityFlowCoordinator(router: router)
      return flow
    } // end if
  } // end func make module flow coordinator
} // end extension final class OSCAMobilityUIDI
