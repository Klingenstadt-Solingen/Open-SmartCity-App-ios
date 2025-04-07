//
//  CityDI+DeeplinkHandler.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.09.22.
//

import Foundation

extension AppDI.CityDI {
  var deeplinkScheme: String {
    return self
      .dependencies
      .deeplinkScheme
  }// end var deeplinkScheme
  
  func makeDeeplinkPrefixes() -> [String] {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let deeplinkScheme = deeplinkScheme
    let home = "\(deeplinkScheme)://home"
    let poi = "\(deeplinkScheme)://poi"
    let sensorstation = "\(deeplinkScheme)://sensorstation"
    let events = "\(deeplinkScheme)://events"
    let districts = "\(deeplinkScheme)://district"
    let prefixes: [String] = [home,
                              poi,
                              sensorstation,
                              events,
                              districts]//end let prefixes
    return prefixes
  }// end func makeDeeplinkPrefixes
}// end extension final class
