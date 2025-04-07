//
//  AppDI+OSCAMapDICopntainer.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 01.03.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import Foundation
import OSCAEssentials
import OSCAMap
import OSCAMapUI
import OSCANetworkService

extension AppDI {
  final class OSCAMapUIDI {
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults: UserDefaults
      let deeplinkScheme: String
    } // end struct Dependencies
    
    private let dependencies: OSCAMapUIDI.Dependencies
    
    var mapFlow: Coordinator?
    var dataModule: OSCAMap?
    
    init(dependencies: OSCAMapUIDI.Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    // MARK: - Feature UI Module Color settings
    
    func makeOSCAMapUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    } // end makeOSCAMapUIColorSettings
    
    // MARK: - Feature UI Module TypeFace settings
    
    func makeOSCAMapUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    } // end func makeOSCAMapUIFontSettings
    
    // MARK: - Feature UI Module Config
    
    func makeOSCAMapUIConfig() -> OSCAMapUI.Config {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAMapUI.Config(title: "OSCAMapUI",
                              fontConfig: makeOSCAMapUIFontSettings(),
                              colorConfig: makeOSCAMapUIColorSettings())
    } // end func makeOSCAMapUIConfig
    
    // MARK: - Feature UI Module dependencies
    
    func makeOSCAMapUIModuleDependencies() -> OSCAMapUI.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAMap.Dependencies = OSCAMap.Dependencies(networkService: dependencies.networkService,
                                                                              userDefaults: dependencies.userDefaults)
      let dataModule = OSCAMap.create(with: dataModuleDependencies)
      return OSCAMapUI.Dependencies(moduleConfig: makeOSCAMapUIConfig(),
                                    dataModule: dataModule)
    } // end func makeOSCAMapUIModuleDependencies
    
    func makeOSCAMapModuleDependencies() -> OSCAMap.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dependendies = OSCAMap.Dependencies(defaultGeoPoint: AppDI.Environment.defaultLocation,
                                              networkService: dependencies.networkService,
                                              userDefaults: dependencies.userDefaults)
      return dependendies
    } // end func makeOSCAMapUIModuleDependencies
    
    // MARK: - Feature UI Module
    
    func makeOSCAMapUIModule() -> OSCAMapUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAMapUI.create(with: makeOSCAMapUIModuleDependencies())
    } // end func makeOSCAMapUIModule
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAMapModule() -> OSCAMap {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let mapModule = dataModule {
        return mapModule
      } else {
        let mapModule = OSCAMap.create(with: makeOSCAMapModuleDependencies())
        dataModule = mapModule
        return mapModule
      }// end if
    } // end func makeOSCAWeather
  } // end final class OSCAMapUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAMapUIDI {
  /// singleton `Coordinator`
  func makeOSCAMapFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let mapFlow = mapFlow {
      return mapFlow
    } else {
      let flow = makeOSCAMapUIModule()
        .getMapFlowCoordinator(router: router)
      return flow
    }// end if
  } // end func makeOSCAMapFlowCoordinator
}// end extension final class OSCAMapUIDI
