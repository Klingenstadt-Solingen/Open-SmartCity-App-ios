//
//  SettingsDI+DeeplinkHandler.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.09.22.
//

import Foundation

extension AppDI.SettingsDI {
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
    let settings = "\(deeplinkScheme)://settings"
    let prefixes: [String] = [settings]//end let prefixes
    return prefixes
  }// end func makeDeeplinkPrefixes
}// end extension final class SettingsDI
