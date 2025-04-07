//
//  SolingenAppFlowDI+DeeplinkHandlers.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.09.22.
//

import Foundation
import OSCAEssentials
import UIKit

extension AppDI.SolingenAppFlowDI {
  func makeDeeplinkHandlers(window: UIWindow,
                            onDismissed: (() -> Void)?) -> [OSCADeeplinkHandeble] {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let homeTabRoot = dependencies
      .appDI
      .makeOSCASolingenDI()
      .makeHomeTabRootDeeplinkHandeble(window: window,
                                       onDismissed: onDismissed)
    return [homeTabRoot]
  }// end func makeDeeplinkHandlers
}// end extension final class SolingenAppFlowDI
