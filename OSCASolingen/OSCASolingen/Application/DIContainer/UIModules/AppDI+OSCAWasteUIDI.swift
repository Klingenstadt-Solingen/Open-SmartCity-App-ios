//
//  AppDI+OSCAWasteUIDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.06.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCANetworkService
import OSCAWaste
import OSCAWasteUI
import OSCASafariView
import UIKit

extension AppDI {
  final class OSCAWasteUIDI {
    /**
     `OSCAWasteUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let webViewModule : OSCASafariView
      let networkService: OSCANetworkService
      let userDefaults  : UserDefaults
      let deeplinkScheme: String
    }// end Dependencies
    
    private let dependencies: Dependencies
    
    var wasteFlow: Coordinator?
    var wasteSetupFlow: Coordinator?
    var wasteWidgetFlow: Coordinator?
    var dataModule: OSCAWaste?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCAWasteDependencies() -> OSCAWasteDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies = OSCAWasteDependencies(defaultGeoPoint: AppDI.Environment.defaultLocation,
                                                         networkService: self.dependencies.networkService,
                                                         userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAWasteModule() -> OSCAWaste {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let wasteModule = dataModule {
        return wasteModule
      } else {
        let wasteModule = OSCAWaste.create(with: makeOSCAWasteDependencies())
        dataModule = wasteModule
        return wasteModule
      }// end if
    }// end func makeOSCAWasteModule
    
    // MARK: - Feature UI Module user address
    func makeOSCAWasteUIUserAddress() throws -> OSCAWasteAddress {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return try dependencies.userDefaults.getOSCAWasteAddress()
    }
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCAWasteUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.3,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAWasteUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCAWasteUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }
    
    // MARK: - Feature UI Module Config
    func makeOSCAWasteUIConfig() -> OSCAWasteUI.Config {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAWasteUI.Config(title: "OSCAWasteUI",
                                fontConfig: makeOSCAWasteUIFontSettings(),
                                colorConfig: makeOSCAWasteUIColorSettings(),
                                cornerRadius: 10.0,
                                shadow: makeOSCAWasteUIShadowSettings(),
                                userAddress: try? makeOSCAWasteUIUserAddress(),
                                enableBinTypeFilter: true)
    }
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAWasteUIModuleDependencies() -> OSCAWasteUI.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAWasteUI.Dependencies(moduleConfig: makeOSCAWasteUIConfig(),
                                      dataModule: makeOSCAWasteModule(), webViewModule: self.dependencies.webViewModule)
    }
    
    // MARK: - Feature UI Module
    func makeOSCAWasteUIModule() -> OSCAWasteUI {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAWasteUI.create(with: makeOSCAWasteUIModuleDependencies())
    }
  }
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAWasteUIDI {
  /// singleton `Coordinator`
  func makeOSCAWasteFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let wasteFlow = wasteFlow {
      return wasteFlow
    } else {
      let flow = makeOSCAWasteUIModule()
        .getWasteFlowCoordinator(router: router)
      wasteFlow = flow
      return flow
    }// end if
  }// end func makeOSCAWasteFlowCoordinator
  
  /// singleton `Coordinator`
  func makeOSCAWasteSetupFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let wasteSetupFlow = wasteSetupFlow {
      return wasteSetupFlow
    } else {
      let flow = makeOSCAWasteUIModule()
        .getWasteSetupFlowCoordinator(router: router)
      wasteSetupFlow = flow
      return flow
    }// end if
  }// end func makeOSCAWasteSetupFlowCoordinator
  
  /// singleton `Coordinator`
  func makeOSCAWasteWidgetFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let wasteWidgetFlow = self.wasteWidgetFlow {
      return wasteWidgetFlow
      
    } else {
      let flow = self.makeOSCAWasteUIModule()
        .getWasteWidgetFlowCoordinator(router: router)
      self.wasteWidgetFlow = flow
      return flow
    }
  }
}// end extension final class OSCAWasteUIDI
