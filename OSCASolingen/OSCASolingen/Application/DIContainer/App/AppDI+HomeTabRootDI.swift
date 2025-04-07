//
//  AppDI+HomeTabRootDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//  Reviewed by Stephan Breidenbach on 20.06.2022
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCAMap
/* Disabled module Corona
import OSCACoronaUI
 */
import OSCAPressReleasesUI
import OSCAPressReleases
import OSCAPressReleasesUI
import OSCAWeather
import UIKit

extension AppDI {
  final class HomeTabRootDI {
    struct Dependencies {
      let appDI: AppDI
      let deeplinkScheme: String
      let onDismissed: (() -> Void)?
    } // end struct Dependencies
    
    let dependencies: HomeTabRootDI.Dependencies
    
    var homeTabRootCoordinator: HomeTabRootCoordinator?
    
    init(dependencies: HomeTabRootDI.Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    func makeBottomBarDependencies() -> OSCABottomBar.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      #if DEBUG
      let networkService = dependencies.appDI.devNetworkService
      #else
      let networkService = dependencies.appDI.productionNetworkService
      #endif
      let deeplinkScheme = deeplinkScheme
      let userDefaults = dependencies.appDI.userDefaults
      let dependencies = OSCABottomBar.Dependencies(networkService: networkService,
                                                    userDefaults: userDefaults,
                                                    deeplinkScheme: deeplinkScheme)
      return dependencies
    }// end func makeBottomBarDependencies
    
    func makeBottomBar() -> OSCABottomBar {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dependencies = makeBottomBarDependencies()
      return OSCABottomBar(dependencies: dependencies)
    }// end func makeBottomBar
    
    // MARK: - HomeTabRootScene
    func makeHomeTabRootViewModel(actions: HomeTabRootViewModel.Actions) -> HomeTabRootViewModel {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let oscaBottomBar = makeBottomBar()
      return HomeTabRootViewModel(oscaBottomBar: oscaBottomBar, actions: actions)
    } // end func makeHomeTabRootViewModel
    
    /// singleton HomeTabRootCoordinator
    func makeHomeTabRootCoordinator(window: UIWindow) -> HomeTabRootCoordinator {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let homeTabRootCoordinator = homeTabRootCoordinator {
        return homeTabRootCoordinator
      } else {
        let coordinator = HomeTabRootCoordinator(window: window,
                                                 dependencies: self)
        homeTabRootCoordinator = coordinator
        return coordinator
      }// end if
    } // end func makeHomeTabRootCoordinator
  } // end final class HomeTabRootDI
}// end extension public final class AppDI

// MARK: - HomeTabRootCoordinatorDependencies conformance
extension AppDI.HomeTabRootDI: HomeTabRootCoordinatorDependencies {
  var onDismissed: (() -> Void)? {
    return dependencies.onDismissed
  }// end var onDismissed
  
  /// make a `RootNavigationRouter`
  /// - Parameter rootBarItem: specialized `UITabBarItem`
  /// - Parameter navigationController: 
  func makeRootNavigationRouter(with rootBarItem: RootBarItem,
                                on navigationController: UINavigationController,
                                homeTabRootViewController: HomeTabRootViewController) -> RootNavigationRouter {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// add a tab bar item to the `navController`
    navigationController.tabBarItem = rootBarItem
    /// construct a new `RootNavigationRouter` instance  with `navController` for `rootNavigationController`
    let rootNavigationRouter = RootNavigationRouter(navigationController: navigationController,
                                                    homeTabRootViewController: homeTabRootViewController)
    return rootNavigationRouter
  }// end func makeRootNavigationRouter
  
  func makeHomeTabRootViewController(actions: HomeTabRootViewModel.Actions) -> HomeTabRootViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return HomeTabRootViewController.create(with: makeHomeTabRootViewModel(actions: actions))
  } // end func makeHomeTabRootViewController
  
  /* Disabled module Corona
  func makeCoronaCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeOSCASolingen()
      .getOSCACoronaCoordinator(router: router)
  }// end func makeCoronaCoordinator
   */
  
  func makeCityCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeOSCASolingen()
      .getCityCoordinator(router: router)
  } // end func makeCityCoordinator
  
  func makeSettingsCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeOSCASolingen()
      .getSettingsCoordinator(router: router)
  } // end func makeSettingsCoordinator
  
  func makeTownhallCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeOSCASolingen()
      .getTownhallCoordinator(router: router)
  } // end func makeTownhallCoordinator
  
  func makeServiceCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeOSCASolingen()
      .getServiceCoordinator(router: router)
  } // end func makeServiceCoordinator
  
  func makeOSCAPressReleasesCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeOSCASolingen()
      .getOSCAPressReleasesCoordinator(router: router)
  }// end func makeOSCAPressReleasesCoordinator
} // end extension final class HomeTabRootDI
