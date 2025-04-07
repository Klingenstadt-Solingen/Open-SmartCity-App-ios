//
//  OSCAClassRequestResource+BottomBar.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.08.22.
//

import Foundation
import OSCANetworkService

extension OSCAClassRequestResource {
  /// `ClassReqestRessource` for bottom tab bar data
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://parse-dev.solingen.de/classes/BottomBar'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use `OSCAClassRequestResource`
  static func bottomBar(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<OSCABottomBar.BottomBar> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let parseClass = OSCABottomBar.BottomBar.parseClassName
    return OSCAClassRequestResource<OSCABottomBar.BottomBar>(baseURL: baseURL, parseClass: parseClass, parameters: query, headers: headers)
  }// end static func bottomBar
}// end extension public struct OSCAClassRequestResource
