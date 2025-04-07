//
//  UserDefaults.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//  Reviewed by Stephan Breidenbach on 14.02.24
//

import Foundation
import OSCAEssentials
import OSCANetworkService

// MARK: - Onboarding
extension UserDefaults {
  public var isOnboardingComplete: Bool {
    get{
      return bool(forKey: Self.Keys.onboardingCompletion.rawValue)
    }// end getter
    set{
      set(newValue, forKey: Self.Keys.onboardingCompletion.rawValue)
    }// end setter
  }// end public var isOnboardingComplete
}// end extension class UserDefaults
// MARK: - Parse Installation
extension UserDefaults {
  /// parse installation property
  public var parseInstallation: ParseInstallation? {
    get{
      guard let data = self.data(forKey: ParseInstallation.Keys.parseInstallation.rawValue),
            let parseInstallation = try? OSCACoding.jsonDecoder().decode(ParseInstallation.self, from: data)
      else { return nil }
      return parseInstallation
    }// end getter
    set{
      guard let parseInstallation = newValue,
            let data = try? OSCACoding.jsonEncoder().encode(parseInstallation) else { return }
      set(data, forKey: ParseInstallation.Keys.parseInstallation.rawValue)
    }// end setter
  }// end public var parseInstallation
}// end extension class UserDefaults
// MARK: - SessionToken
extension UserDefaults {
  public var parseSessionToken: String? {
    get{
      string(forKey: Self.Keys.sessionToken.rawValue)
    }// end getter
    set{
      set(newValue, forKey: Self.Keys.sessionToken.rawValue)
    }// end setter
  }// end public var parseSessionToken
}// end extension class UserDefaults

