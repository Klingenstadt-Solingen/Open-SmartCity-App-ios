//
//  AppDelegate+ErrorHandling.swift
//  Solingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit
import OSCASolingen

extension AppDelegate {
  /// [based upon](https://www.swiftbysundell.com/articles/propagating-user-facing-errors-in-swift/)
  override func handle(_ error: Error,
                       from viewController: UIViewController? = nil,
                       retryHandler: @escaping () -> Void) {
    super.handle(error,
                 from: viewController,
                 retryHandler: retryHandler)
  }// end override func handle
}// end extension class AppDelegate
