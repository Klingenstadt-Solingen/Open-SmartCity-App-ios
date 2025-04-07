//
//  OnboardingParseConfig.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import Foundation
import OSCAEssentials

/// An object for the parse-server configs
public struct OnboardingParseConfig {
  public init(params: JSON? = nil,
              masterKeyOnly: JSON? = nil) {
    self.params = params
    self.masterKeyOnly = masterKeyOnly
  }// end public init
  
  /// Contains all parse-server config parameters declared in `Params`.
  public var params: JSON?
  
  public var masterKeyOnly: JSON?
  
  /// The privacy policy text config parameter.
  public var privacyText: String? {
    guard let params = self.params,
          let privacyTextString: String = params["privacyText"] else { return nil }
    return privacyTextString
  }// end public var privacyText
}// end public struct OnboardingParseConfig

extension OnboardingParseConfig: OSCAParseConfig {}
