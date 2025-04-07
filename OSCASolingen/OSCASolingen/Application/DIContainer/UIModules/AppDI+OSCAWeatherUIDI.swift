//
//  AppDI+OSCAWeatherUIDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 07.02.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import Foundation
import OSCAEssentials
import OSCAWeather
import OSCAWeatherUI
import OSCANetworkService
import UIKit

extension AppDI {
  final class OSCAWeatherUIDI {
    /**
     `OSCAWeatherUIModuleDIContainer.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService  : OSCANetworkService
      let userDefaults    : UserDefaults
      let deeplinkScheme: String
    }// end struct Dependencies
    
    private let dependencies: Dependencies
    private var uiModule: OSCAWeatherUI?
    
    var weatherFlow: Coordinator?
    var dataModule: OSCAWeather?
    
    init(dependencies: OSCAWeatherUIDI.Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCAWeatherDependencies() -> OSCAWeatherDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAWeatherDependencies = OSCAWeatherDependencies(networkService: self.dependencies.networkService,
                                                                                    userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }// end func makeOSCAWeatherDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAWeatherModule() -> OSCAWeather {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let weatherModule = dataModule {
        return weatherModule
      } else {
        let weatherModule = OSCAWeather.create(with: makeOSCAWeatherDependencies())
        dataModule = weatherModule
        return weatherModule
      }// end if
    }// end func makeOSCAWeather
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCAWeatherUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }// end func makeOSCAWeatherUIShadowSettings
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAWeatherUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }// end func makeOSCAWeatherUIColorSettings
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCAWeatherUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func makeOSCAWeatherUIFontSettings
    
    // MARK: - Feature UI Module Config
    func makeOSCAWeatherUIConfig(selectedWeatherObservedId: String) -> OSCAWeatherUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAWeatherUIConfig(title: "OSCAWeatherUI",
                                 cornerRadius: 10.0,
                                 shadow: makeOSCAWeatherUIShadowSettings(),
                                 fontConfig: makeOSCAWeatherUIFontSettings(),
                                 colorConfig: makeOSCAWeatherUIColorSettings(),
                                 selectedWeatherObservedId: selectedWeatherObservedId)
    }// end func makeOSCAWeatherUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAWeatherUIModuleDependencies(selectedWeatherObservedId: String) -> OSCAWeatherUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAWeatherUIDependencies(dataModule: makeOSCAWeatherModule(),
                                       moduleConfig: makeOSCAWeatherUIConfig(selectedWeatherObservedId:selectedWeatherObservedId))// end return
    }// end func makeOSCAWeatherUIModuleDependencies
    
    // MARK: - Feature UI Module
    /// singleton UI module
    func makeOSCAWeatherUIModule(selectedWeatherObservedId: String) -> OSCAWeatherUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let uiModule = uiModule {
        return uiModule
      } else {
        return OSCAWeatherUI.create(with: makeOSCAWeatherUIModuleDependencies(selectedWeatherObservedId:selectedWeatherObservedId))
      }
    }
  }// end final class OSCAWeatherUIModuleDIContainer
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAWeatherUIDI {
  /// singleton `Coordinator`
  func makeOSCAWeatherFlowCoordinator(router: Router,
                                      selectedWeatherObservedId: String = "") -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
      let flow = makeOSCAWeatherUIModule(selectedWeatherObservedId: selectedWeatherObservedId)
        .getWeatherFlowCoordinator(router: router)
      weatherFlow = flow
      return flow
  }// end func makeOSCAWeatherFlowCoordinator
  
  /// singleton `Coordinator`
  func makeOSCAWeatherStationSelectionFlowCoordinator(
    router: Router,
    selectedWeatherObservedId: String = "",
    didSelectStation: ((String) -> Void)? = nil) -> Coordinator {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let flow = makeOSCAWeatherUIModule(selectedWeatherObservedId: selectedWeatherObservedId)
        .getWeatherStationSelectionFlowCoordinator(router: router, didSelectStation: didSelectStation)
      weatherFlow = flow
      return flow
  }
    
    func makeOSCAWeatherListFlowCoordinator(
      router: Router,
      selectedWeatherObservedId: String = "",
      didSelectStation: ((String) -> Void)? = nil) -> Coordinator {
        let flow = makeOSCAWeatherUIModule(selectedWeatherObservedId: selectedWeatherObservedId)
          .getWeatherListFlowCoordinator(router: router, didSelectStation: didSelectStation)
        weatherFlow = flow
        return flow
    }
}// end extension final class OSCAWeatherUIDI
