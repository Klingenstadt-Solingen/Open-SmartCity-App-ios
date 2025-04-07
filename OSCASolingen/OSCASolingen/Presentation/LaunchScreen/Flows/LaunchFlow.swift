//
//  LaunchFlow.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit
import OSCAEssentials

/// `Coordinator` class `LaunchFlow`'s dependencies
protocol LaunchFlowDependencies {
  var deeplinkScheme: String { get }
  var firstStartDeeplinkURL: URL? { get }
  var presentOnboarding: () -> Void { get }
  var presentMain: (URL?) -> Void { get }
  var presentLogin: () -> Void { get }
  func makeLaunchViewController(url: URL?,
                                actions: LaunchViewModel.Actions) -> LaunchViewController?
}// end protocol LaunchFlowDependencies


public final class LaunchFlow: NSObject {
  var onDismissed: (() -> Void)?
  
  public var children: [Coordinator] = []
  
  public var router: Router
  
  let dependencies: LaunchFlowDependencies
  
  weak var launchVC: LaunchViewController?
  
  init(router: Router,
       dependencies: LaunchFlowDependencies) {
    self.router = router
    self.dependencies = dependencies
  }// end init
  
  func showOnboarding() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    dependencies.presentOnboarding()
  }// end func showOnboarding
  
  func showMain(url: URL? = nil) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    dependencies.presentMain(url)
  }// end func showMain
  
  func showLogin() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    dependencies.presentLogin()
  }// end func showLogin
  
  func showLaunchView(url: URL? = nil,
                      animated: Bool,
                      onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let launchVC = launchVC {
      router.present(launchVC,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      let actions = LaunchViewModel.Actions(presentOnboarding: showOnboarding,
                                            presentMain: showMain,
                                            presentLogin: showLogin)
      guard let vc: LaunchViewController = dependencies.makeLaunchViewController(url: url,
                                                                                 actions: actions)
      else {
        return
      }
      router.present(vc,
                     animated: animated,
                     onDismissed: onDismissed)
      launchVC = vc
    }// end if
  }// end func showLaunchView
}// end public final class LaunchFlow

extension LaunchFlow: Coordinator {
  public func present(animated: Bool,
                      onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let url = self.dependencies.firstStartDeeplinkURL {
      showLaunchView(url: url,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      showLaunchView(animated: animated,
                     onDismissed: onDismissed)
    }// end if
  }// end public func present
}// end extension public final class LaunchFlow


