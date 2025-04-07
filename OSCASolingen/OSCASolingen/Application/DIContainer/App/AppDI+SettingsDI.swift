//
//  AppDI+SettingsDI.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 20.06.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCAWeather
import OSCAWasteUI
import UIKit

extension AppDI {
  final class SettingsDI {
    struct Dependencies {
      let appDI: AppDI
      let deeplinkScheme: String
    } // end struct Dependencies
    
    let dependencies: SettingsDI.Dependencies
    
    var settingsFlow: SettingsFlow?
    var settings: Settings?
    
    init(dependencies: SettingsDI.Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    /// singleton `Settings`
    func makeSettings() -> Settings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let settings = settings {
        return settings
      } else {
#if DEBUG
        let networkService = dependencies.appDI.devNetworkService
#else
        let networkService = dependencies.appDI.productionNetworkService
#endif
        let userDefaults = dependencies.appDI.userDefaults
        let dataDependencies = Launch.Dependencies(networkService: networkService,
                                                   userDefaults: userDefaults)
        if let launchData = dependencies.appDI.launchDI?.makeLaunchData(dependencies: dataDependencies) {
          let dataDependencies = Settings.Dependencies(
            networkService: networkService,
            userDefaults: userDefaults,
            launchData: launchData)
          let oscaSettings = Settings(dependencies: dataDependencies)
          settings = oscaSettings
          return oscaSettings
        } else {
          let launchData = Launch(dependencies: dataDependencies)
          let dataDependencies = Settings.Dependencies(
            networkService: networkService,
            userDefaults: userDefaults,
            launchData: launchData)
          let oscaSettings = Settings(dependencies: dataDependencies)
          settings = oscaSettings
          return oscaSettings
        }// end if
      }// end if
    }// end func makeSettings
    
    func makeOSCAWeatherModule() -> OSCAWeather {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let module = dependencies
        .appDI
        .makeOSCAWeatherUIDI()
        .makeOSCAWeatherModule()
      return module
    }
    
    func makeSettingsViewModel(actions: SettingsViewModelActions,
                               data: Settings,
                               weatherModule: OSCAWeather) -> SettingsViewModel {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return SettingsViewModel(actions: actions,
                               settings: data,
                               weatherModule: weatherModule)
    } // end func makeModuleNavigationViewModel
    
    /// singleton `SettingsFlow`
    func makeSettingsFlowCoordinator(router: Router) -> SettingsFlow {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let settingsFlow = settingsFlow {
        return settingsFlow
      } else {
        let flow = SettingsFlow(router: router, dependencies: self)
        settingsFlow = flow
        return flow
      }// end if
    } // end func make makeSettingsFlowCoordinator
  } // end final class SettingsDI
}// end extension public final class AppDI

// MARK: - SettingsFlowCoordinatorDependencies conformance
extension AppDI.SettingsDI: SettingsFlowDependencies {
  func makeSettingsViewController(actions: SettingsViewModelActions) -> SettingsViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let weatherModule = makeOSCAWeatherModule()
    let cityViewModel = makeSettingsViewModel(actions: actions,
                                              data: makeSettings(),
                                              weatherModule: weatherModule)
    return SettingsViewController.create(with: cityViewModel)
  } // end func makeCityViewController
  
  func makeLegallyViewController(actions: LegallyViewModelActions, screenTitle: String, text: String) -> LegallyViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let viewModel = makeLegallyViewModel(actions: actions, data: makeSettings(), screenTitle: screenTitle, text: text)
    return LegallyViewController.create(with: viewModel)
  }
  
  func makeLegallyViewModel(actions: LegallyViewModelActions, data: Settings, screenTitle: String, text: String) -> LegallyViewModel {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return LegallyViewModel(actions: actions, data: data, screenTitle: screenTitle, text: text)
  }
  
  func makeOSCAWeatherStationSelectionCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCAWeatherUIDI()
      .makeOSCAWeatherStationSelectionFlowCoordinator(router: router)
  }
    
    func makeOSCAWeatherListCoordinator(router: Router) -> Coordinator {
      return dependencies
        .appDI
        .makeOSCAWeatherUIDI()
        .makeOSCAWeatherListFlowCoordinator(router: router)
    }
  
  func makeOSCAWasteSetupCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCAWasteUIDI()
      .makeOSCAWasteSetupFlowCoordinator(router: router)
  }// end func makeOSCAWasteSetupFlowCoordinator
}// end extension final class SettingsDI
