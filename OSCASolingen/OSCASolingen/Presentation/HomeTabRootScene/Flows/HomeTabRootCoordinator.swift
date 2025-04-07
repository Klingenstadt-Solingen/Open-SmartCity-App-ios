//
//  HomeTabRootCoordinator.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//

import OSCAEssentials
/* Disabled module Corona
import OSCACoronaUI
 */
import OSCAPressReleasesUI
import UIKit

/// Container class `HomeTabRootCoordinator`'s dependencies
protocol HomeTabRootCoordinatorDependencies {
  var onDismissed: (() -> Void)? { get }
  var deeplinkScheme: String { get }
  func makeDeeplinkPrefixes() -> [String]
  func makeRootNavigationRouter(with rootBarItem: RootBarItem,
                                on navigationController: UINavigationController,
                                homeTabRootViewController: HomeTabRootViewController) -> RootNavigationRouter
  func makeHomeTabRootViewController(actions: HomeTabRootViewModel.Actions) -> HomeTabRootViewController
  func makeCityCoordinator(router: Router) -> Coordinator
  /* Disabled module Corona
  func makeCoronaCoordinator(router: Router) -> Coordinator
   */
  func makeSettingsCoordinator(router: Router) -> Coordinator
  func makeOSCAPressReleasesCoordinator(router: Router) -> Coordinator
  func makeTownhallCoordinator(router: Router) -> Coordinator
  func makeServiceCoordinator(router: Router) -> Coordinator
} // end protocol HomeTabRootCoordinatorDependencies


/// A container class including `RootBarItem` keyed `RootNavigationRouter`s
/// and child `Coordinator`s accessable via `BottomTabBar`
///[see TabBarControllers](https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/ViewControllerCatalog/Chapters/TabBarControllers.html#//apple_ref/doc/uid/TP40011313-CH3-SW1)
public final class HomeTabRootCoordinator: NSObject {
  /// closure
  var onDismissed: (() -> Void)?

  /// `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
  public var children: [Coordinator] = []
  
  /// `UIWindow` instance
  public var window: UIWindow
  
  /// List of `RootBarItem` keyed `RootNavigationRouters`
  var rootNavigationRouters: [RootBarItem:RootNavigationRouter] = [:]

  /// dependencies injected via initializer DI conforming to the `HomeTabRootCoordinatorDependencies` protocol
  let dependencies: HomeTabRootCoordinatorDependencies
  
  /// `weak`reference to `HomeTabRootViewController` instance
  public weak var homeTabRootViewController: HomeTabRootViewController?
  
  /// inject window and dependencies via initializer
  /// - Parameter window: `UIWindow` instance
  /// - Parameter dependencies: `HomeTabRootCoordinatorDependencies`
  init(window: UIWindow,
       dependencies: HomeTabRootCoordinatorDependencies
  ) {
    self.window = window
    self.dependencies = dependencies
    self.onDismissed = dependencies.onDismissed
  } // end init router, dependencies
  
  /// initializes `BottomTabBar` item with it's view model and view controller
  ///
  ///
  /// - Parameter homeTabItemViewModel: `BottomTabBar` item's view model
  /// - Parameter homeTabRootViewController: `BottomTabBar`item's view controller
  /// - Returns: a new `UINavigationController` instance
  private func setup(with homeTabItemViewModel: HomeTabItemViewModel,
                     homeTabRootViewController: HomeTabRootViewController) -> UINavigationController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    #warning("window.rootViewController as? UINavigationController")
    /// init `navController`
    let navigationController = UINavigationController()
    /// init tab bar item with home tab item view model
    let tabBarItem = RootBarItem.fill(with: homeTabItemViewModel)
    /// init root navigation router
    let rootNavigationRouter = dependencies.makeRootNavigationRouter(with: tabBarItem,
                                                                     on: navigationController,
                                                                     homeTabRootViewController: homeTabRootViewController)
    /// add `rootNavigatonRouter` to the list of `RootNavigationRouter`s `rootNavigationRouters` `
    rootNavigationRouters[tabBarItem] = rootNavigationRouter
    ///  construct `Coordinator` flow from `homeTabItemViewModel` with `rootNavigationRouter`
    ///  and add it to `children` list of `Coordinator`s
    addFlowToHomeTabItem(tabBarItem, with: rootNavigationRouter)
    return navigationController
  } // end func setupNavigationController
  

  /// Each view controller in the tab bar controller’s viewControllers property is a view controller for a corresponding tab in the tab bar
  /// - Parameter homeTabItemViewModels: list of `BottomTabBar` view model
  /// - Parameter homeTabMoreTitle: title string for the tab item in case there are more than five items in the `BottomTabBar`
  private func initializeRouters(homeTabItemViewModels: [HomeTabItemViewModel], /* viewModels */
                                 homeTabMoreTitel: String /* Home Tab More title*/) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    
    /// The `homeTabRootViewController` does exist already!
    guard let homeTabRootViewController = self.homeTabRootViewController,
    /// the list of `homeTabItemViewModels` is NOT empty!
          !homeTabItemViewModels.isEmpty else { return }
    resetRouters()
    
    /// new list of `UINavigationController` `navControllers`
    /// Create a content view controller for each tab.
    let navControllers: [UINavigationController] = homeTabItemViewModels.compactMap {
      setup(with: $0, homeTabRootViewController: homeTabRootViewController) }
    
    /// Add the view controllers to an array and assign that array to your tab bar controller’s viewControllers property.
    /// add `navControllers` to the empty list `viewControllers` of the ashured existing `homeTabRootViewController`
    homeTabRootViewController.viewControllers = navControllers
    ///
    if navControllers.count > 5 {
      homeTabRootViewController.moreNavigationController.tabBarItem.title = homeTabMoreTitel
    } // end if
  } // end private func initializeRouters
  
  private func resetRouters() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// is the list of `RootNavigationRouters`Not empty? Then empty it
    if !rootNavigationRouters.isEmpty { rootNavigationRouters.removeAll() }
    /// is the list of `Coordinator` children NOT empty? Then empty it
    if !children.isEmpty { children.removeAll() }
    /// Does the `homeTabRootViewController`exist and has it a list of `viewControllers`?
    guard let homeTabRootViewController = self.homeTabRootViewController,
          var viewControllers = homeTabRootViewController.viewControllers else { return }
    /// Is the list of `viewControllers`NOT empty? Then empty it
    if !viewControllers.isEmpty { viewControllers.removeAll() }
  } // end private func resetRouters
  
  ///
  /// - Parameter item: `BottomTabBar` item `RootBarItem`
  /// - Parameter rootNavigationRouter:
  private func addFlowToHomeTabItem(_ item: RootBarItem,
                                    with rootNavigationRouter: Router) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var flow: Coordinator?
    switch item.id {
    case "tabbaritem_home_title":
      flow = dependencies
        .makeCityCoordinator(router: rootNavigationRouter)
      /* Disabled module Corona
    case "tabbaritem_corona_title":
      flow = dependencies
        .makeCoronaCoordinator(router: rootNavigationRouter)
       */
    case "tabbaritem_settings_title":
      flow = dependencies
        .makeSettingsCoordinator(router: rootNavigationRouter)
    case "tabbaritem_townhall_title":
      flow = dependencies
        .makeTownhallCoordinator(router: rootNavigationRouter)
    case "tabbaritem_press_title":
      flow = dependencies
        .makeOSCAPressReleasesCoordinator(router: rootNavigationRouter)
    case "tabbaritem_service_title":
      flow = dependencies
        .makeServiceCoordinator(router: rootNavigationRouter)
    default: return
    } // end default
    /// `flow` exists!
    guard let flow = flow else { return }
    ///
    presentChild(flow,
                 animated: false,
                 onDismissed: self.onDismissed)
  } // end private func addFlowToHomeTabItem
  
  private func changeRootViewController(_ vc: UIViewController,
                                        animated: Bool = true) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    window.rootViewController = vc
    // add animation
    UIView.transition(with: window,
                      duration: 0.5,
                      options: [.transitionFlipFromLeft],
                      animations: nil,
                      completion: nil)
  }// end private func changeRootViewController
  
  func showHomeTabRoot(animated: Bool,
                       onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let homeTabRootViewController = homeTabRootViewController {
      /*self.router.present(homeTabRootViewController,
                          animated: animated,
                          onDismissed: onDismissed)*/
      changeRootViewController(homeTabRootViewController)
    } else {
      /// create actions
      let actions: HomeTabRootViewModel.Actions = HomeTabRootViewModel.Actions(
        initializeNavigationItems: initializeRouters,
        resetNavigationItems: resetRouters,
        handleDeeplink: handle(homeTabItem:with:)
      ) // end let actions
      
      // instantiate home tab root view controller
      /// Create a new UITabBarController object.
      let vc = dependencies
        .makeHomeTabRootViewController(actions: actions)
      /*
      /// Install `HomeTabRootViewController` directly as a `window’s root view controller.
      /// Set the tab bar controller as the root view controller of your window (or otherwise present it in your interface)
      self.router.present(vc,
                          animated: animated,
                          onDismissed: onDismissed)*/
      changeRootViewController(vc)
      self.homeTabRootViewController = vc
    }// end if
  }// end func showHomeTabRoot
  
  public func present(animated: Bool,
                      onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    
    // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
    showHomeTabRoot(animated: animated,
                    onDismissed: onDismissed)
  } // end public func present
} // end public final class HomeTabRootCoordinator

// MARK: Accessors
extension HomeTabRootCoordinator {
  /// get `homeTabItem` matching `RootBarItem` in `RouteNavigationRouter` from `rootNavigationRouters` list
  /// - Parameter homeTabItem: `BottomTabBar` item view model
  /// - Returns: matching `RootBarItem`
  func getRootBarItem(from homeTabItem: HomeTabItemViewModel) -> RootBarItem? {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return rootNavigationRouters.keys.first(where: { $0.id == homeTabItem.id })
  }// end func get root bar item from view model
  
  /// get child `Coordinator` matching `RootNavigationRouter` from `children`
  /// - Parameter rootNavigationRouter:
  func getChildCoordinator(from rootNavigationRouter: RootNavigationRouter) -> Coordinator? {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return children.first(where: { ($0.router as? RootNavigationRouter) === rootNavigationRouter })
  }// end func get getChildCoordinator
}// end extension final class HomeTabRootCoordinator

// MARK: - present / remove child Coordinator
extension HomeTabRootCoordinator {
  
  /// add `child` `Coordinator`to `children` list of `Coordinator`s and present `child` `Coordinator`
  /// - Parameter child: child `Coordinator` to present
  /// - Parameter animated: flag for animated presentation
  /// - Parameter onDismissed: closure executed on dismissal
  public func presentChild(_ child: Coordinator,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    children.append(child)
    child.present(animated: animated) { [weak self, weak child] in
      guard let self = self, let child = child else { return }
      self.removeChild(child)
      onDismissed?()
    } // end on dismissed closure
  } // end public func presentChild
  
  /// removes child `Coordinator` from `children`
  /// - Parameter child: child `Coordinator` to remove
  private func removeChild(_ child: Coordinator) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// `children` includes `child`!!
    guard let index = children.firstIndex(where: { $0 === child }) else { return } // end guard
    children.remove(at: index)
  } // end private func removeChild
}// end extension public final class HomeTabRootCoordinator

