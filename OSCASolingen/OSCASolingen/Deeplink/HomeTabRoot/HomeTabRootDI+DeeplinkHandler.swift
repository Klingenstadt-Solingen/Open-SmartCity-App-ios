//
//  HomeTabRootDI+DeeplinkHandler.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 18.09.22.
//

import Foundation

extension AppDI.HomeTabRootDI {
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
    let townhall = "\(deeplinkScheme)://townhall"
    let service = "\(deeplinkScheme)://service"
    let settings = "\(deeplinkScheme)://settings"
    let pressReleases = "\(deeplinkScheme)://pressreleases"
    let contact = "\(deeplinkScheme)://contact"
    let defect = "\(deeplinkScheme)://defect"
    /* Disabled module Corona
    let corona = "\(deeplinkScheme)://corona"
     */
    let jobs = "\(deeplinkScheme)://jobs"
    let poi = "\(deeplinkScheme)://poi"
    let transport = "\(deeplinkScheme)://transport"
    let waste = "\(deeplinkScheme)://waste"
    let sensorstation = "\(deeplinkScheme)://sensorstation"
    let events = "\(deeplinkScheme)://events"
    let coworking = "\(deeplinkScheme)://coworking"
    let appointments = "\(deeplinkScheme)://appointments"
    let culture = "\(deeplinkScheme)://art"
    let district = "\(deeplinkScheme)://district"
    let prefixes: [String] = [home,
                              townhall,
                              service,
                              settings,
                              pressReleases,
                              contact,
                              defect,
    /* Disabled module Corona
                              corona,
     */
                              jobs,
                              poi,
                              transport,
                              waste,
                              sensorstation,
                              events,
                              coworking,
                              appointments,
                              culture,
                              district]//end let prefixes
    return prefixes
  }// end func makeDeeplinkPrefixes
}// end extension final class AppDI.HomeTabRootDI
