//
//  Launch+Parse.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.02.24.
//

import Foundation
import OSCAEssentials
import Combine
import OSCANetworkService

// MARK: - Parse
extension Launch {
  public typealias LoginPublisher = AnyPublisher<ParseUser, OSCANetworkError>
  
  func loginAnonymously() -> LoginPublisher {
    self.parseUser.loginAnonymously(networkService: self.networkService)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  }// end func loginAnonymously
  
  public typealias InstallationPublisher = AnyPublisher<ParseInstallation, OSCANetworkError>
  
  func syncInstallation() -> InstallationPublisher {
    self.parseInstallation.sync(networkService: self.networkService)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  }// end func getInstallation
} // end extension class Launch

