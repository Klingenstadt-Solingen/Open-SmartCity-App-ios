//
//  TownhallDI+DeeplinkHandler.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.09.22.
//

import Foundation

extension AppDI.TownhallDI {
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
    let townhall = "\(deeplinkScheme)://townhall"
    let contact = "\(deeplinkScheme)://contact"
    let defect = "\(deeplinkScheme)://defect"
    let waste = "\(deeplinkScheme)://waste"
    let appointments = "\(deeplinkScheme)://appointments"
    let prefixes: [String] = [townhall,
                              contact,
                              defect,
                              waste,
                              appointments]//end let prefixes
    return prefixes
  }// end func makeDeeplinkPrefixes
}// end extension final class TownhallDI
