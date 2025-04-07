//
//  OSCASGBaseAppDelegate+config.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.11.23.
//

import Foundation
import OSCAEssentials

extension OSCASGBaseAppDelegate {
  public static var config: OSCAConfig {
#if DEBUG
    return .develop
#else
    return .production
#endif
  }// end public static var config
}// end extension OSCASGBaseAppDelegate
