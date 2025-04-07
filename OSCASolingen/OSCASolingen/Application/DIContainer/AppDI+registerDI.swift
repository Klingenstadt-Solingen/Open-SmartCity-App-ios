//
//  AppDI+registerDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 07.02.23.
//

import Foundation
import OSCAEssentials
import OSCANetworkService

extension AppDI {
  /// register `AppDI` and it's dependencies to `config` respecting `DIContainer`
  /// * `OSCAEssentials`
  /// * `UserDefaults`
  /// * `OSCANetworkService`
  /// - parameter _ config: default .production
  public static func registerDI(_ config: OSCAConfig = .production) throws -> Void {
    let diContainer = DIContainer.container(for: config)
    // register essentials
    try OSCAEssentials.registerDI()
    // register user defaults dependencies
    try UserDefaults.registerDI()
    // register network service dependencies
    try OSCANetworkService.registerDI()
    // register app configuration dependencies
    try AppConfiguration.registerDI()
    // register developer deeplink scheme closure to DI Container
    diContainer.register(.by(key: "deeplinkScheme"),
                            DIContainer.deeplinkScheme)
    // register app config
    diContainer.register(.by(key: "OSCASGAppConfig"),
                         DIContainer.appConfig)
  }// end public static func registerDI
}// end extension public class AppDI

extension DIContainer {
  /// Type property closure for `AppConfig`
  static var appConfig = { (_: Resolvable) throws -> AppDI.Config in
    return AppDI.Config()
  }// end static var appConfig
}// end extension DIContainer
