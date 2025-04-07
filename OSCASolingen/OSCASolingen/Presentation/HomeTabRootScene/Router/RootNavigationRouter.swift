//
//  RootNavigationRouter.swift
//  OSCAEssentials
//
//  Created by Stephan Breidenbach on 20.11.21.
//  Reviewed by Stephan Breidenbach on 14.07.22
//  Reviewed by Stephan Breidenbach on 17.09.22
//  Reviewed by Stephan Breidenbach on 16.02.22
//

import UIKit
import OSCAEssentials

class RootNavigationRouter: NSObject {
  // MARK: - Instance Properties
  private unowned var rootVC: UIViewController?
  
  private unowned var homeTabRootViewController: HomeTabRootViewController?
  
  private let navigationController: UINavigationController
  
  private var onDismissForViewController: [UIViewController: (() -> Void)] = [:]
  
  init(navigationController: UINavigationController,
       homeTabRootViewController: HomeTabRootViewController){
    self.navigationController = navigationController
    self.homeTabRootViewController = homeTabRootViewController
    super.init()
    setupNavigationController()
  }// end init
  
}// end public class RootNavigationRouter

extension RootNavigationRouter {
  func navigateToRoot(animated: Bool) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let _ = rootVC {
      // is the view controller presented modally?
      if let presentedViewController = navigationController.presentedViewController {
        performOnDismissed(for: presentedViewController)
        navigationController.dismiss(animated: animated)
      }// end if
      let poppedVC = self.navigationController.popToRootViewController(animated: animated)
      if let poppedVC = poppedVC {
        for vc in poppedVC { performOnDismissed(for: vc) }
      }// end if
    } else {
      /// there is NO `rootViewController`, so set it to `viewController`
      return
    }// end if
  }// end navigateToRoot
  
  func selectTabBarItem(with index: Int) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let tabBarController = self.navigationController.tabBarController,
          let viewControllers = tabBarController.viewControllers,
          viewControllers.indices.contains(index) else { return }
    tabBarController.selectedIndex = index
  }// end private func selectTabBarItem
}// end extension RootNavigationRouter

// MARK: - Router conformance
extension RootNavigationRouter: Router {
  
  func present(_ viewController: UIViewController,
                      animated: Bool,
                      onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    OSCAMatomoTracker.shared.trackNavigation(viewController)
    /// NOT the first `viewController`!!!
    if self.rootVC != nil {
      if let topVC = self.navigationController.topViewController {
        if !(topVC === viewController) {
          self.navigationController.pushViewController(viewController, animated: animated)
        } else {
#if DEBUG
          print("\(String(describing: self)): \(#function)")
#endif
          if let tabBar = navigationController.tabBarController as? HomeTabRootViewController,
             let homeTabRootViewController = homeTabRootViewController,
             tabBar === homeTabRootViewController,
             let tabBarItem = navigationController.tabBarItem as? RootBarItem,
             tabBar.selectedIndex != tabBarItem.tag
          {
#if DEBUG
            print("\(String(describing: self)): \(#function)")
#endif
            /// horizontal navigation to
            tabBar.selectedIndex = tabBarItem.tag
          }// end if
        }// end if
      }// end if
    } else {
      /// there is NO `rootViewController`, so set it to `viewController`
      self.navigationController.setViewControllers([viewController], animated: animated)
      self.rootVC = viewController
    }// end
    self.onDismissForViewController[viewController] = onDismissed
  }// end public func present
  
  func presentModalViewController(_ viewController: UIViewController,
                                         animated: Bool,
                                         onDismissed: (() -> Void)? = nil) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.onDismissForViewController[viewController] = onDismissed
    self.navigationController.present(viewController, animated: animated)
  }// end public func presentModalViewController
  
  public func navigateBack(animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // is the view controller presented modally?
    if let presentedViewController = navigationController.presentedViewController {
      performOnDismissed(for: presentedViewController)
      navigationController.dismiss(animated: animated)
    } else if let lastViewController = navigationController.viewControllers.last {
      performOnDismissed(for: lastViewController)
      navigationController.popViewController(animated: animated)
    }// end if
  }// end public func navigateBack
  
  func dismiss(animated: Bool) -> Void{
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    navigateToRoot(animated: false)
    
    guard let vc = self.navigationController.viewControllers.first else { return }
    vc.dismiss(animated: animated){
      self.performOnDismissed(for: vc)
    }// end dismiss
  }// end public func dismiss
  
  /**
   Within `performOnDismiss(for:)`, you guard that there is an `onDismiss`for the given `viewController`. If not, you simply `return`early. Otherwise, you call `onDismiss`and remove it from `onDismissForViewController`
   */
  private func performOnDismissed(for
                                  viewController: UIViewController) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let onDismiss =
            self.onDismissForViewController[viewController] else {
      return
    }// end guard
    onDismiss()
    self.onDismissForViewController[viewController] = nil
  }// end private func performOnDismissed
}// end extension public class RootNavigationRouter

// MARK: - UINavigationControllerDelegate conformance
extension RootNavigationRouter: UINavigationControllerDelegate {
  func setupNavigationController() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.navigationController.delegate = self
  }// end func setupNavigationController
  
  /// called just before `navigationController` displays a `ViewController`'s view and navigation item properties
  public func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) -> Void {
    guard self.navigationController == navigationController,
          navigationController.delegate === self else { return }
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end public func navigation controller will show view controller
  
  
  /**
   You get the `from`view controller from the `navigationController.transitionCoordinator`and verify it's not contained within `navigationController.viewControllers`. This indicates that the view controller was popped, and in response, you call `performOnDismissed`to do the on-dismiss action for the given view controller.
   */
  public func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool) -> Void {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      guard self.navigationController == navigationController,
            navigationController.delegate === self,
            let dismissedViewController = self.navigationController.transitionCoordinator?.viewController(forKey: .from),
            !self.navigationController.viewControllers.contains(dismissedViewController) else { return }// end guard
      performOnDismissed(for: dismissedViewController)
    }// end public func navigation controller did show view controller
}// extension public class RootNavigationRouter
