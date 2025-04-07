//
//  OSCAClassRequestResource+OSCAAppointment.swift
//  OSCAAppointments
//
//  Created by Ömer Kurutay on 19.02.23.
//

import OSCANetworkService
import Foundation

extension OSCAClassRequestResource {
  /// `ClassReqestRessource` for appointment data
  ///
  ///```console
  /// curl -vX GET \
  /// -H "X-Parse-Application-Id: ApplicationId" \
  /// -H "X-PARSE-CLIENT-KEY: ClientKey" \
  /// -H 'Content-Type: application/json' \
  /// 'https://THE.SERVER/classes/TableMenu'
  ///  ```
  /// - Parameters:
  ///   - baseURL: The base url of your parse-server
  ///   - headers: The authentication headers for parse-server
  ///   - query: HTTP query parameters for the request
  /// - Returns: A ready to use `OSCAClassRequestResource`
  static func appointment(baseURL: URL, headers: [String: CustomStringConvertible], query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<OSCAAppointment> {
    let parseClass = OSCAAppointment.parseClassName
    return OSCAClassRequestResource<OSCAAppointment>(
      baseURL: baseURL,
      parseClass: parseClass,
      parameters: query,
      headers: headers)
  }
}
