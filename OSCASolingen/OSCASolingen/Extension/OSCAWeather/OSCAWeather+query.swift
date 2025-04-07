//
//  OSCAWeather+query.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.03.24.
//

import Foundation
import OSCAEssentials
import OSCAWeather

extension OSCAWeather {
  public static func query(with geoPoint: OSCAGeoPoint?)-> [String: String] {
    var query: [String: String] = [:]
    guard let geoPoint = geoPoint else { return query }
    query["where"] = "{\"geopoint\": {\"$nearSphere\": {\"__type\": \"GeoPoint\",\"latitude\": \(geoPoint.latitude),\"longitude\": \(geoPoint.longitude)}}, \"maintenance\": false }"
    return query
  }// end public static func query with geo point
}// end extension OSCAWeather

