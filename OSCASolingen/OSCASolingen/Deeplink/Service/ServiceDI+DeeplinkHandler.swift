//
//  ServiceDI+DeeplinkHandler.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.09.22.
//

import Foundation

extension AppDI.ServiceDI {
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
    let service = "\(deeplinkScheme)://service"
    let jobs = "\(deeplinkScheme)://jobs"
    let transport = "\(deeplinkScheme)://transport"
    let coworking = "\(deeplinkScheme)://coworking"
    let mobility = "\(deeplinkScheme)://mobilitymonitor"
    let culture = "\(deeplinkScheme)://art"
    let prefixes: [String] = [service,
                              jobs,
                              transport,
                              coworking,
                              mobility,
                              culture]//end let prefixes
    return prefixes
  }// end func makeDeeplinkPrefixes
}// end extension final class ServiceDI
