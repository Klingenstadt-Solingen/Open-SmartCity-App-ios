//
//  AppDI+OSCADefectUIDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 01.03.22.
//  Reviewed by Stephan Breidenbach on 22.06.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCANetworkService
import OSCADefectUI
import OSCADefect
import UIKit

extension AppDI {
  final class OSCADefectUIDI {
    /**
     `OSCADefectUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults  : UserDefaults
      let deeplinkScheme: String
    }// end struct Dependencies
    
    private let dependencies: Dependencies
    
    var defectFlow: Coordinator?
    var dataModule: OSCADefect?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCADefectDependencies() -> OSCADefectDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let defaultLocation = AppDI.Environment.defaultLocation
      let dataModuleDependencies: OSCADefectDependencies = OSCADefectDependencies(defaultLocation: defaultLocation, networkService: self.dependencies.networkService,
                                                                                  userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }// end func makeOSCADefectDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCADefectModule() -> OSCADefect {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let defectModule = dataModule {
        return defectModule
      } else {
        let defectModule = OSCADefect.create(with: makeOSCADefectDependencies())
        dataModule = defectModule
        return defectModule
      }// end if
    }// end func makeOSCADefect
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCADefectUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }// end func makeOSCADefectUIShadowSettings
    
    // MARK: - Feature UI Module Color settings
    func makeOSCADefectUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }// end func makeOSCADefectUIColorSettings
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCADefectUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func makeOSCADefectUIFontSettings
    
    // MARK: - Feature UI Module Config
    func makeOSCADefectUIConfig() -> OSCADefectUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCADefectUIConfig(title: "OSCADefectUI",
                                personalData: [.fullName, .email],
                                cornerRadius: 10.0,
                                shadow: makeOSCADefectUIShadowSettings(),
                                fontConfig: makeOSCADefectUIFontSettings(),
                                colorConfig: makeOSCADefectUIColorSettings())
    }// end func makeOSCADefectUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCADefectUIModuleDependencies() -> OSCADefectUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCADefectUIDependencies(dataModule  : makeOSCADefectModule(),
                                      moduleConfig: makeOSCADefectUIConfig())
    }// end func makeOSCADefectUIModuleDependencies
    
    // MARK: - Feature UI Module
    func makeOSCADefectUIModule() -> OSCADefectUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCADefectUI.create(with: makeOSCADefectUIModuleDependencies())
    }// end func makeOSCADefectUIModule
  }// end final class OSCADefectUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCADefectUIDI {
  /// singleton `Coordinator`
  func makeOSCADefectFormFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let defectFlow = defectFlow {
      return defectFlow
    } else {
      let flow = makeOSCADefectUIModule()
        .getDefectFlowCoordinator(router: router)
      defectFlow = flow
      return flow
    }// end if
  }// end func makeOSCADefectFormFlowCoordinator
}// end extension final class OSCADefectUIDI
