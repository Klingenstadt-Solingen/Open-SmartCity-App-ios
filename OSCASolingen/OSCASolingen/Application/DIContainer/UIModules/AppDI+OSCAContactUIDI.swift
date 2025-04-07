//
//  AppDI+OSCAContactUIDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 07.02.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCANetworkService
import OSCAContactUI
import OSCAContact
import OSCAEssentials
import UIKit

extension AppDI {
  final class OSCAContactUIDI {
    
    /**
     `OSCAContactUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults:   UserDefaults
      let deeplinkScheme: String
    }// end struct Dependencies
    
    private let dependencies: Dependencies
    
    var contactFlow: Coordinator?
    var dataModule: OSCAContact?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCAContactDependencies() -> OSCAContactDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAContactDependencies = OSCAContactDependencies(networkService: self.dependencies.networkService,
                                                                                    userDefaults: self.dependencies.userDefaults,
                                                                                    deeplinkScheme: self.dependencies.deeplinkScheme
      )
      return dataModuleDependencies
    }// end func makeOSCAContactDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAContactModule() -> OSCAContact {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let contactModule = dataModule {
        return contactModule
      } else {
        let contactModule = OSCAContact.create(with: makeOSCAContactDependencies())
        dataModule = contactModule
        return contactModule
      }// end if
    }// end func makeOSCAContact
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCAContactUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAContactUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }// end func make OSCAColorSettings for conact ui
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCAContactUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func make OSCAFontSettings for contact ui
    
    // MARK: - Feature UI Module Config
    func makeOSCAContactUIConfig() -> OSCAContactUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAContactUIConfig(title: "OSCAContactUI",
                                 personalData: [.fullName, .email],
                                 cornerRadius: 10.0,
                                 shadow: makeOSCAContactUIShadowSettings(),
                                 fontConfig: makeOSCAContactUIFontSettings(),
                                 colorConfig: makeOSCAContactUIColorSettings())
    }// end func make OSCAContactUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAContactUIModuleDependencies() -> OSCAContactUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAContactUIDependencies(moduleConfig: makeOSCAContactUIConfig(),
                                       dataModule: makeOSCAContactModule())
    }// end func make OSCAContactUI dependencies
    
    // MARK: - Feature UI Module
    func makeOSCAContactUIModule() -> OSCAContactUI {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      return OSCAContactUI.create(with: makeOSCAContactUIModuleDependencies())
    }// end func makePressReleaseModule
  }// end final class OSCAContactUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAContactUIDI {
  /// singleton `Coordinator`
  func makeOSCAContactFormFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let contactFlow = contactFlow {
      return contactFlow
    } else {
      let flow = makeOSCAContactUIModule()
        .getOSCAContactFormFlowCoordinator(router: router)
      contactFlow = flow
      return flow
    }// end if
  }// end func make module flow coordinator
}// end extension final class OSCAContactUIDI
