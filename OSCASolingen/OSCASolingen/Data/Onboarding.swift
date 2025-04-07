//
//  Onboarding.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import OSCAEssentials
import OSCANetworkService
import Foundation
import Combine

struct Onboarding {
  struct Dependencies {
    let networkService: OSCANetworkService
    let userDefaults  : UserDefaults
    
    init(networkService: OSCANetworkService,
         userDefaults  : UserDefaults) {
      self.networkService = networkService
      self.userDefaults   = userDefaults
    }
  }
  
  public private(set) var networkService: OSCANetworkService
  public private(set) var userDefaults: UserDefaults
  
  init(dependencies: Onboarding.Dependencies) {
    networkService = dependencies.networkService
    userDefaults = dependencies.userDefaults
  }
  
}

// MARK: - Data access

extension Onboarding {
  /// Downloads all config parameters declared in `OSCAOnboardingParseConfig` from parse-server
  public func fetchAllParseConfigParams() -> AnyPublisher<OnboardingParseConfig,OSCASGError> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
    let publisher: AnyPublisher<OnboardingParseConfig,OSCANetworkError> = self.networkService
      .fetch(OSCAConfigRequestResource<OnboardingParseConfig>
        .onboardingParseConfig(baseURL: self.networkService.config.baseURL,
                               headers: self.networkService.config.headers))
    return publisher
      .mapError(OSCASGError.map(_:))
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  }
}
