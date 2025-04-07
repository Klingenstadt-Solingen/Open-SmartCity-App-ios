//
//  ParseInstallation+Save.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 07.10.22.
//

import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public extension ParseInstallation {
  typealias Publisher = AnyPublisher<ParseInstallation, OSCASGError>
  
  func save(networkService: OSCANetworkService) -> AnyPublisher<ParseInstallation, OSCANetworkError> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var headers = networkService.config.headers
    if let sessionToken = networkService.userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
    
    let installationRequest = OSCAInstallationRequestResource<ParseInstallation>(
      baseURL: networkService.config.baseURL,
      headers: networkService.config.headers,
      parseInstallation: self)
    
    return networkService.put(installationRequest)
  }// end func save
}// end extension ParseInstallation

