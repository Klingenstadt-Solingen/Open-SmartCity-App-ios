//
//  ParseInstallation+Get.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.02.24.
//

import Foundation
import Combine
import OSCAEssentials
import OSCANetworkService

extension ParseInstallation {
  func sync(networkService: OSCANetworkService) -> AnyPublisher<ParseInstallation, OSCANetworkError> {
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
  }// end func sync
}// end extension public struct ParseInstallation
