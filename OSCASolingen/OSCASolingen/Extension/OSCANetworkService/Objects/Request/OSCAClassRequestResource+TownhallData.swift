//
//  OSCAClassRequestResource+TownhallData.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.06.22.
//

import Foundation
import OSCANetworkService 

extension OSCAClassRequestResource {
  /// `ClassReqestRessource` for  townhall menu data#
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/TownhallData'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use `OSCAClassRequestResource`
  static func townhallData(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<TownhallData> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let parseClass = TownhallData.parseClassName
    return OSCAClassRequestResource<TownhallData>(baseURL: baseURL, parseClass: parseClass, parameters: query, headers: headers)
  }// end static func townhallData
}// end extension public struct OSCAClassRequestResource
