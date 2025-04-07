//
//  OSCAConfigRequestResource+Onboarding.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import OSCANetworkService
import Foundation

extension OSCAConfigRequestResource {
  /// ConfigReqestRessource for onboarding config params
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  /// - Returns: A ready to use OSCAConfigRequestResource
  static func onboardingParseConfig(baseURL: URL, headers: [String: CustomStringConvertible]) -> OSCAConfigRequestResource<OnboardingParseConfig> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return OSCAConfigRequestResource<OnboardingParseConfig>(
      baseURL: baseURL,
      headers: headers)
  }
}
