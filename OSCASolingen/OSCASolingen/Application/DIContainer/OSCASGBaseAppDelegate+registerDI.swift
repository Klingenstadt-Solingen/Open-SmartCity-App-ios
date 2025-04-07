//
//  OSCASGBaseAppDelegate+registerDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.11.23.
//

import Foundation
import OSCAEssentials

extension OSCASGBaseAppDelegate {
  /// register `OSCASGBaseAppDelegate` and it's dependencies to `config` respecting `DIContainer`
  /// * `AppDI`
  public static func registerDI(_ config: OSCAConfig = .production) throws -> Void {
    let diContainer = DIContainer.container(for: config)
    // register app di
    try AppDI.registerDI(config)
  }// end public static func registerDI
}// end extension OSCASGBaseAppDelegate
