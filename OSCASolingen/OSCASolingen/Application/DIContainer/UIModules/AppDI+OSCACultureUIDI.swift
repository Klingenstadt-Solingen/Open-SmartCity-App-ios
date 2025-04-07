//
//  AppDI+OSCACultureUIDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.09.22.
//

import Foundation
import OSCAEssentials
import OSCACultureUI
import OSCACulture
import OSCANetworkService

extension AppDI {
  final class OSCACultureUIDI {
    let dependencies: AppDI.OSCACultureUIDI.Dependencies
    
    var uiModule: OSCACultureUI?
    var beaconSearchFlow: BeaconSearchFlow?
    var dataModule: OSCACulture?
    
    init(dependencies: AppDI.OSCACultureUIDI.Dependencies) {
      self.dependencies = dependencies
    }// end init
  }// end final class OSCACultureUIDI
}// end extension final class AppDI

extension AppDI.OSCACultureUIDI {
  struct Dependencies {
    let appDI: AppDI
    let networkService: OSCANetworkService
    let userDefaults: UserDefaults
    let deeplinkScheme: String
  }// end struct Dependencies
}// end extension final class OSCACultureUIDI

// MARK: - data module
extension AppDI.OSCACultureUIDI {
  func makeOSCACultureDependencies() -> OSCACulture.Dependencies {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let networkService = dependencies
      .networkService
    let userDefaults = dependencies
      .userDefaults
    let dependencies = OSCACulture.Dependencies(networkService: networkService,
                                                userDefaults: userDefaults)
    return dependencies
  }// end func makeOSCACultureDependencies
  
  /// singleton data module
  func makeOSCACulture() -> OSCACulture {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let dataModule = self.dataModule {
      return dataModule
    } else {
      let dependencies = makeOSCACultureDependencies()
      let module = OSCACulture.create(with: dependencies)
      self.dataModule = module
      return module
    }// end if
  }// end func makeOSCACulture
}// end extension final class OSCACultureUIDI

extension AppDI.OSCACultureUIDI {
  func makeOSCACultureUIConfig() -> OSCACultureUI.Config {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let config = OSCACultureUI.Config(title: "OSCACultureUI",
                                      fontConfig: OSCAFontSettings(),
                                      colorConfig: OSCAColorSettings())
    return config
  }// end func makeOSCACultureUIConfig
  
  func makeOSCACultureUIDependencies() -> OSCACultureUI.Dependencies {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let config = makeOSCACultureUIConfig()
    let dataModule = makeOSCACulture()
    let dependencies = OSCACultureUI.Dependencies(moduleConfig: config,
                                                  dataModule: dataModule)
    return dependencies
  }// end func makeOSCACultureUIDependencies
  
  /// singleton `OSCACultureUI`
  func makeOSCACultureUI() -> OSCACultureUI {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let module = uiModule {
      return module
    } else {
      let dependencies = makeOSCACultureUIDependencies()
      let module = OSCACultureUI.create(with: dependencies)
      uiModule = module
      return module
    }// end if
  }// end func makeSOCACultureUI
  
  /// singleton flow
  func makeBeaconSearchFlow(router: Router) -> BeaconSearchFlow {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = beaconSearchFlow {
      return flow
    } else {
      let flow = makeOSCACultureUI()
        .getBeaconSearchFlow(router: router)
      beaconSearchFlow = flow
      return flow
    }// end if
  }// end makeBeaconSearchFlow
}// end extension final class AppDI
