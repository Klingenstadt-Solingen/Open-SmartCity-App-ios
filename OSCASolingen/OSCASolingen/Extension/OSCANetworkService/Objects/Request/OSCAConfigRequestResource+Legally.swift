//
//  OSCAConfigRequestResource+Legally.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 07.10.22.
//

import OSCANetworkService
import Foundation

extension OSCAConfigRequestResource {
  /// ConfigReqestRessource for legally config params
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  /// - Returns: A ready to use OSCAConfigRequestResource
  static func legallyParseConfig(baseURL: URL, headers: [String: CustomStringConvertible]) -> OSCAConfigRequestResource<LegallyParseConfig> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return OSCAConfigRequestResource<LegallyParseConfig>(
      baseURL: baseURL,
      headers: headers)
  }
}
