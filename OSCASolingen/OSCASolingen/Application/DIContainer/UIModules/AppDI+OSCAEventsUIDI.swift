//
//  AppDI+OSCAEventsUIDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 07.02.22.
//  Reviewed by Stephan Breidenbach on 29.08.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import UIKit
import OSCANetworkService
import OSCAEssentials
import OSCAEventsUI
import OSCAEvents

extension AppDI {
  final class OSCAEventsUIDI {
    struct Dependencies {
      let networkService  : OSCANetworkService
      let userDefaults    : UserDefaults
      let deeplinkScheme  : String
    }// end struct Dependencies
    
    private let dependencies: OSCAEventsUIDI.Dependencies
    
    var eventsFlow: Coordinator?
    var dataModule: OSCAEvents?
    
    init(dependencies: OSCAEventsUIDI.Dependencies) {
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCAEventsDependencies() -> OSCAEventsDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let appStoreURL = AppDI.Environment.appStoreUrl
      let dataModuleDependencies: OSCAEventsDependencies = OSCAEventsDependencies(
        appStoreURL: appStoreURL,
        networkService: self.dependencies.networkService,
        userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }// end func makeOSCAEventsDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAEventsModule() -> OSCAEvents {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let eventsModule = dataModule {
        return eventsModule
      } else {
        let eventsModule = OSCAEvents.create(with: makeOSCAEventsDependencies())
        dataModule = eventsModule
        return eventsModule
      }// end if
    }// end func makeOSCAEvents
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAEventsUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings(
        navigationTintColor: UIColor.white.darker(),
        navigationTitleTextColor: UIColor.white.darker(),
        navigationBarColor: UIColor.primary)
    }// end makeOSCAEventsUIColorSettings
    
    // MARK: - Feature UI Module TypeFace settings
    func makeOSCAEventsUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func makeOSCAEventsUIFontSettings
    
    // MARK: - Feature UI Module Config
    func makeOSCAEventsUIConfig() -> OSCAEventsUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAEventsUIConfig(title: "OSCAEventsUI",
                                fontConfig: makeOSCAEventsUIFontSettings(),
                                colorConfig: makeOSCAEventsUIColorSettings(),
                                placeholderImage: UIImage(named: "placeholder_header_image", in: OSCASolingen.bundle, with: .none))
    }// end func makeOSCAEventsUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAEventsUIModuleDependencies() -> OSCAEventsUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAEventsUIDependencies(moduleConfig: makeOSCAEventsUIConfig(),
                                      dataModule: makeOSCAEventsModule(),
                                      eventWatchlistMaxStorageLimit: 1000
      )// end return
    }// end func makeOSCAEventsUIModuleDependencies
    
    // MARK: - Feature UI Module
    func makeOSCAEventsUIModule() -> OSCAEventsUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAEventsUI.create(with: makeOSCAEventsUIModuleDependencies())
    }// end func makeOSCAEventsUIModule
  }// end final class OSCAEventsUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAEventsUIDI {
  /// singleton `Coordinator`
  func makeOSCAEventsFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let eventsFlow = eventsFlow {
      return eventsFlow
    } else {
      let flow = makeOSCAEventsUIModule()
        .getOSCAEventsFlowCoordinator(router: router)
      eventsFlow = flow
      return flow
    }// end if
  }// end func makeOSCAEventsFlowCoordinator
}// end extension final class OSCAEventsUIDI


