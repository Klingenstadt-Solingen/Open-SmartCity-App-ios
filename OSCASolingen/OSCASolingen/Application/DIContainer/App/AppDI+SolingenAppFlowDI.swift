//
//  AppDI+SolingenAppFlowDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.09.22.
//

import UIKit
import OSCAEssentials

extension AppDI {
  final class SolingenAppFlowDI {
    let dependencies: AppDI.SolingenAppFlowDI.Dependencies
    
    var appFlow: SolingenAppFlow?
    
    init(dependencies: AppDI.SolingenAppFlowDI.Dependencies) {
      self.dependencies = dependencies
    }// end init
  }// end final class SolingenAppFlowDI
}// end extension final class AppDI

// MARK: - Dependencies
extension AppDI.SolingenAppFlowDI {
  struct Dependencies {
    let appDI: AppDI
  }// end struct Dependencies
}// end extension final class SolingenAppFlowDI

// MARK: - OSCACoreApp flow
extension AppDI.SolingenAppFlowDI {
  func makeSolingenAppFlowDependencies(window: UIWindow,
                               onDismissed: (() -> Void)?) -> SolingenAppFlow.Dependencies {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let dependencies = SolingenAppFlow.Dependencies(window: window,
                                                    appDI: dependencies.appDI,
                                                    onDismissed: onDismissed)
    return dependencies
  }// end func makeSolingenAppFlowDependencies
  
  /// singleton `SolingenAppFlow`
  func makeSolingenAppFlow(window: UIWindow,
                           onDismissed: (() -> Void)?) -> SolingenAppFlow {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let appFlow = appFlow {
      return appFlow
    } else {
      let dependencies = makeSolingenAppFlowDependencies(window: window,
                                                 onDismissed: onDismissed)
      let flow = SolingenAppFlow(dependencies: dependencies)
      appFlow = flow
      return flow
    }// end if
  }// end func makeSolingenAppFlow
}// end extension final class SolingenAppFlowDI

extension AppDI.SolingenAppFlowDI {
  func makeNavigationController(window: UIWindow) -> UINavigationController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let rootViewController = window.rootViewController,
          let navigationController = rootViewController as? UINavigationController
    else { fatalError("window's rootViewController is not properly initialized!") }
    return navigationController
  }// end func makeNavigationController
  
  func makeNavigationRouter(navigationController: UINavigationController) -> NavigationRouter {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let router = NavigationRouter(navigationController: navigationController)
    return router
  }// end func makeNavigationRouter
}// end extension final class SolingenAppFlowDI
