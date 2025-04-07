//
//  LegallyParseConfig.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 07.10.22.
//

import Foundation
import OSCAEssentials

/// An object for the parse-server configs
public struct LegallyParseConfig {
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
  
  /// The settings imprint text config parameter.
  public var imprintText: String? {
    guard let params = self.params,
          let imprintTextString: String = params["imprintText"] else { return nil }
    return imprintTextString
  }// end public var imprintText
}// end public struct LegallyParseConfig

extension LegallyParseConfig: OSCAParseConfig {}
