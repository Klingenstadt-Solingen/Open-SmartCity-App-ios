//
//  DIContainer+deeplinkScheme.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 07.02.23.
//

import Foundation
import OSCAEssentials

extension DIContainer {
  public static var deeplinkScheme = { (diContainer: Resolvable) throws -> String in
#if DEBUG
    print("make deeplinkScheme closure: \(#function)")
#endif
    guard let diContainer = diContainer as? DIContainer else { throw ResolvableError.cast(DIContainer.self) }
    @InjectedSafe(.by(type: AppConfiguration.self),
                  container: diContainer,
                  mode: .shared)
    var appConfig: AppConfiguration?
    guard let appConfig = appConfig else { throw DIContainer.Error.notImplemented }
    let deeplinkScheme = appConfig.deeplinkScheme
    return deeplinkScheme
  }// end public static var deeplinkScheme
}// extension 
