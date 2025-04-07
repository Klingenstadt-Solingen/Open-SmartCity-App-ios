//
//  OSCASGSceneDelegate+Error.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit

extension OSCASGSceneDelegate {
  func handleOSCASGError(_ oscaSGError: OSCASGError,
                         from viewController: UIViewController? = nil,
                         retryHandler: @escaping () -> Void) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = UIApplication.shared.delegate,
          let appDelegate = delegate as? OSCASGBaseAppDelegate else { return }
    appDelegate.handle(oscaSGError,
                       from: viewController,
                       retryHandler: retryHandler)
  }// end func show alert string
}// end extension OSCASGSceneDelegate

extension UIViewController {
  /// The visible view controller from a given view controller
  var visibleViewController: UIViewController? {
    if let navigationController = self as? UINavigationController {
      return navigationController.topViewController?.visibleViewController
    } else if let tabBarController = self as? UITabBarController {
      return tabBarController.selectedViewController?.visibleViewController
    } else if let presentedViewController = presentedViewController {
      return presentedViewController.visibleViewController
    } else if self is UIAlertController {
      return nil
    } else {
      return self
    }
  }// end var visibleViewController
}// end extension UIViewController
