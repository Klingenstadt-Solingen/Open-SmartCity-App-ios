//
//  AppDI+OSCACoronaUIDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 11.08.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

/* Disabled module Corona

import OSCAEssentials
import OSCANetworkService
import OSCACorona
import OSCACoronaUI
import OSCASafariView
import UIKit

extension AppDI {
  final class OSCACoronaUIDI {
    /**
     `OSCACoronaUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let webViewModule: OSCASafariView
      let networkService: OSCANetworkService
      let userDefaults  : UserDefaults
      let deeplinkScheme: String
    }
    
    private let dependencies: Dependencies
    
    var coronaFlow: Coordinator?
    var dataModule: OSCACorona?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }
    
    // MARK: - Feature Module dependencies
    func makeOSCACoronaDependencies() -> OSCACorona.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCACorona.Dependencies = OSCACorona.Dependencies(networkService: self.dependencies.networkService, userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCACoronaModule() -> OSCACorona {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let coronaModule = dataModule {
        return coronaModule
      } else {
        let coronaModule = OSCACorona.create(with: makeOSCACoronaDependencies())
        dataModule = coronaModule
        return coronaModule
      }// end if
    }// end func makeOSCACoronaModule
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCACoronaUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    func makeOSCACoronaUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCACoronaUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }
    
    // MARK: - Feature UI Module Config
    func makeOSCACoronaUIConfig() -> OSCACoronaUI.Config {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCACoronaUI.Config(title: "OSCACoronaUI",
                                 fontConfig: makeOSCACoronaUIFontSettings(),
                                 colorConfig: makeOSCACoronaUIColorSettings(),
                                 cornerRadius: 10.0,
                                 shadow: makeOSCACoronaUIShadowSettings())
    }
    
    // MARK: - Feature UI Module dependencies
    func makeOSCACoronaUIModuleDependencies() -> OSCACoronaUI.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCACoronaUI.Dependencies(moduleConfig: makeOSCACoronaUIConfig(),
                                       dataModule: makeOSCACoronaModule(),
                                       webViewModule: self.dependencies.webViewModule)
    }
    
    // MARK: - Feature UI Module
    func makeOSCACoronaUIModule() -> OSCACoronaUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCACoronaUI.create(with: makeOSCACoronaUIModuleDependencies())
    }
  }
}// end extension public final class AppD

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCACoronaUIDI {
  /// singleton `Coordinator`
  func makeOSCACoronaFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let coronaFlow = coronaFlow {
      return coronaFlow
    } else {
      let flow = makeOSCACoronaUIModule()
        .getCoronaFlowCoordinator(router: router)
      coronaFlow = flow
      return flow
    }// end if
  }// end func makeOSCACoronaFlowCoordinator
}// end extension final class OSCACoronaUIDI
*/
