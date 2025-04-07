//
//  AppDI+OSCAPublicTransportUIDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 09.05.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCANetworkService
import OSCAPublicTransportUI
import OSCAPublicTransport
import UIKit

extension AppDI {
  final class OSCAPublicTransportUIDI {
    /**
     `OSCAPublicTransportUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults  : UserDefaults
      let deeplinkScheme: String
    }// end Dependencies
    
    private let dependencies: Dependencies
    
    var publicTransportFlow: Coordinator?
    var dataModule: OSCAPublicTransport?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCAPublicTransportDependencies() -> OSCAPublicTransportDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAPublicTransportDependencies = OSCAPublicTransportDependencies(networkService: self.dependencies.networkService,
                                                                                                    userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }// end func  makeOSCAPublicTransportDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAPublicTransportModule() -> OSCAPublicTransport {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let publicTransportModule = dataModule {
        return publicTransportModule
      } else {
        let publicTransportModule = OSCAPublicTransport.create(with: makeOSCAPublicTransportDependencies())
        dataModule = publicTransportModule
        return publicTransportModule
      }// end if
    }// end func makeOSCAPublicTransport
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCAPublicTransportUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }// end func makeOSCAPublicTransportUIShadowSettings
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAPublicTransportUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }// end func makeOSCAPublicTransportUIColorSettings
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCAPublicTransportUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func makeOSCAPublicTransportUIFontSettings
    
    // MARK: - Feature UI Module Config
    func makeOSCAPublicTransportUIConfig() -> OSCAPublicTransportUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAPublicTransportUIConfig(title: "OSCAPublicTransportUI",
                                         cornerRadius: 10.0,
                                         shadow: makeOSCAPublicTransportUIShadowSettings(),
                                         fontConfig: makeOSCAPublicTransportUIFontSettings(),
                                         colorConfig: makeOSCAPublicTransportUIColorSettings())
    }// end func makeOSCAPublicTransportUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAPublicTransportUIModuleDependencies() -> OSCAPublicTransportUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAPublicTransportUIDependencies(dataModule: makeOSCAPublicTransportModule(),
                                               moduleConfig: makeOSCAPublicTransportUIConfig())
    }// end func makeOSCAPublicTransportUIModuleDependencies
    
    // MARK: - Feature UI Module
    func makeOSCAPublicTransportUIModule() -> OSCAPublicTransportUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAPublicTransportUI.create(with: makeOSCAPublicTransportUIModuleDependencies())
    }// end func makeOSCAPublicTransportUIModule
  }// end final class OSCAPublicTransportUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAPublicTransportUIDI {
  /// singleton `Coordinator`
  func makeOSCAPublicTransportFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let publicTransportFlow = publicTransportFlow {
      return publicTransportFlow
    } else {
      let flow = makeOSCAPublicTransportUIModule()
        .getPublicTransportFlowCoordinator(router: router)
      publicTransportFlow = flow
      return flow
    }// end if
  }// end func makeOSCAPublicTransportFlowCoordinator
}// end extension final class OSCAPublicTransportUIDI
