//
//  UserDefaultsKeys.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import Foundation

extension UserDefaults {
  /// UserDefaults keys
  enum Keys: String {
    case onboardingCompletion = "Onboarding_completion"
    case sessionToken = "SessionToken"
    case parseInstallationId = "ParseInstallationId"
  }// end enum Keys
}// end extension UserDefaults

