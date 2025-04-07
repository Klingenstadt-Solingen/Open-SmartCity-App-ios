//
//  AppDI+OSCACoworkingUIDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 04.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.23
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCANetworkService
import OSCACoworkingUI
import OSCACoworking
import UIKit

extension AppDI {
  final class OSCACoworkingUIDI {
    /**
     `OSCACoworkingUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults  : UserDefaults
      let deeplinkScheme: String
    }// end struct Dependencies
    
    private let dependencies: Dependencies
    
    var coworkingFlow: Coordinator?
    var dataModule: OSCACoworking?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCACoworkingDependencies() -> OSCACoworkingDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCACoworkingDependencies = OSCACoworkingDependencies(networkService: self.dependencies.networkService,
                                                                                        userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }// end func  makeOSCACoworkingDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCACoworkingModule() -> OSCACoworking {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let coworkingModule = dataModule {
        return coworkingModule
      } else {
        let coworkingModule = OSCACoworking.create(with: makeOSCACoworkingDependencies())
        dataModule = coworkingModule
        return coworkingModule
      }// end if
    }// end func makeOSCACoworking
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCACoworkingUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }// end func makeOSCACoworkingUIShadowSettings
    
    // MARK: - Feature UI Module Color settings
    func makeOSCACoworkingUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }// end func makeOSCACoworkingUIColorSettings
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCACoworkingUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func makeOSCACoworkingUIFontSettings
    
    // MARK: - Feature UI Module Config
    func makeOSCACoworkingUIConfig() -> OSCACoworkingUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCACoworkingUIConfig(title: "OSCACoworkingUI",
                                   personalData: [.company, .fullName, .email],
                                   cornerRadius: 10.0,
                                   shadow: makeOSCACoworkingUIShadowSettings(),
                                   fontConfig: makeOSCACoworkingUIFontSettings(),
                                   colorConfig: makeOSCACoworkingUIColorSettings())
    }// end func makeOSCACoworkingUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCACoworkingUIModuleDependencies() -> OSCACoworkingUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCACoworkingUIDependencies(dataModule: makeOSCACoworkingModule(),
                                         moduleConfig: makeOSCACoworkingUIConfig())
    }// end func makeOSCACoworkingUIModuleDependencies
    
    // MARK: - Feature UI Module
    func makeOSCACoworkingUIModule() -> OSCACoworkingUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCACoworkingUI.create(with: makeOSCACoworkingUIModuleDependencies())
    }// end func makeOSCACoworkingUIModule
  }// end final class
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCACoworkingUIDI {
  /// singleton `Coordinator`
  func makeOSCACoworkingFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let coworkingFlow = coworkingFlow {
      return coworkingFlow
    } else {
      let flow = makeOSCACoworkingUIModule()
        .getCoworkingFlowCoordinator(router: router)
      coworkingFlow = flow
      return flow
    }// end if
  }// end func makeOSCACoworkingFlowCoordinator
}// end extension final class OSCACoworkingUIDI
