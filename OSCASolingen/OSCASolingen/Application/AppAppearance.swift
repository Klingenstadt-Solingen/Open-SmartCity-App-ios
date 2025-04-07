//
//  AppAppearance.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 01.06.22.
//

import Foundation
import UIKit

final class AppAppearance {
  // MARK: - Method
  static func setupAppearance() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    UINavigationBar.appearance().barTintColor = .black
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
  }// end static func setupAppearance
}// end final class AppAppearance

extension UINavigationController {
  @objc override open var preferredStatusBarStyle: UIStatusBarStyle {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if #available(iOS 13.0, *) {
      return .darkContent
    } else {
      return .lightContent
    }// end if
  }// end @objc override open var preferredStatusBarStyle
}// end extension class UINavigationController

