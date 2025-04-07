//
//  OSCASGBaseAppDelegate+ErrorHandling.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit
import OSCAEssentials

extension OSCASGBaseAppDelegate {
  /// [based upon](https://www.swiftbysundell.com/articles/propagating-user-facing-errors-in-swift/)
  override open func handle(_ error: Error,
                       from viewController: UIViewController? = nil,
                       retryHandler: @escaping () -> Void) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    appFlow?.handle(error,
                    from: viewController,
                    retryHandler: retryHandler)
  }// end override func handle
}// end extension class OSCASGBaseAppDelegate
