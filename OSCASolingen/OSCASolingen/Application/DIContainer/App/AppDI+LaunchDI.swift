//
//  AppDI+LaunchDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import OSCAEssentials
import UIKit

extension AppDI {
  final class LaunchDI {
    struct Dependencies {
      let appDI: AppDI
      let firstStartDeeplinkURL: URL?
      let deeplinkScheme: String
      let presentOnboarding: () -> Void
      let presentMain: (URL?) -> Void
      let presentLogin: () -> Void
      let appFlow: SolingenAppFlow
    } // end struct Dependencies
    
    let dependencies: LaunchDI.Dependencies
    
    var launchFlow: Coordinator?
    
    init(dependencies: LaunchDI.Dependencies) {
      self.dependencies = dependencies
    } // end init
  } // end final class LaunchDI
}// end extension public final class AppDI

// MARK: - HomeTabRootCoordinatorDependencies conformance
extension AppDI.LaunchDI: LaunchFlowDependencies {
  var firstStartDeeplinkURL: URL? {
    dependencies.firstStartDeeplinkURL
  }// end var firstStartDeeplinkURL
  
  var deeplinkScheme: String {
    dependencies.deeplinkScheme
  }// end var deeplinkScheme
  
  var appFlow: SolingenAppFlow {
    dependencies.appFlow
  }// end var appFlow
  
  var presentOnboarding: () -> Void {
    dependencies.presentOnboarding
  }// end var presentOnboarding
  
  var presentMain: (URL?) -> Void {
    dependencies.presentMain
  }// end var presentMain
  
  var presentLogin: () -> Void {
    dependencies.presentLogin
  }// end var presentLogin
  
  func makeLaunchViewController(url: URL?,
                                actions: LaunchViewModel.Actions) -> LaunchViewController? {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return LaunchViewController.create(appFlow: appFlow,
                                       with: makeLaunchViewModel(actions: actions))
  } // end func makeLaunchViewController
  
  func makeLaunchData(dependencies: Launch.Dependencies) -> Launch {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return Launch(dependencies: dependencies)
  }// end func makeLaunchData
  
  func makeLaunchViewModel(actions: LaunchViewModel.Actions) -> LaunchViewModel {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let userDefaults = dependencies.appDI.userDefaults
    #if DEBUG
    let networkService = dependencies.appDI.devNetworkService
    #else
    let networkService = dependencies.appDI.productionNetworkService
    #endif
    
    let dataDependencies = Launch.Dependencies(networkService: networkService,
                                               userDefaults: userDefaults)
    let data = makeLaunchData(dependencies: dataDependencies)
  
    let url = self.dependencies.firstStartDeeplinkURL
    return LaunchViewModel(url: url,
                           actions: actions,
                           data: data)
  }// end makeLaunchViewModel
  
  func makeLaunchFlow(router: Router) -> LaunchFlow {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let dependencies: LaunchFlowDependencies = self
    return LaunchFlow(router: router,
                      dependencies: dependencies)
  }// end func makeLaunchFlow
} // end extension final class LaunchDI
