//
//  OSCAClassRequestResource+TownhallMenu.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 23.06.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  /// `ClassReqestRessource` for service menu data
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/TownhallMenu'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use `OSCAClassRequestResource`
  static func townhallMenu(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<TownhallMenu> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let parseClass = TownhallMenu.parseClassName
    return OSCAClassRequestResource<TownhallMenu>(baseURL: baseURL, parseClass: parseClass, parameters: query, headers: headers)
  }// end static func townhallMenu
}// end extension public struct OSCAClassRequestResource
