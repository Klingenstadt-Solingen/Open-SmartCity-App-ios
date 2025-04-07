//
//  OSCAClassRequestResource+ServiceData.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.06.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  /// `ClassReqestRessource` for legacy service menu data
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/ServiceData'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use `OSCAClassRequestResource`
  static func serviceData(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<ServiceData> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let parseClass = ServiceData.parseClassName
    return OSCAClassRequestResource<ServiceData>(baseURL: baseURL, parseClass: parseClass, parameters: query, headers: headers)
  }// end static func serviceData
}// end extension public struct OSCAClassRequestResource
