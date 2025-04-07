//
//  Launch+UserDefaults.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.02.24.
//

import Foundation
import OSCAEssentials

extension Launch {
  func isPushing(for key: Launch.Keys) -> Bool {
    switch key {
    case .pushCategoryWaste:
      return self.userDefaults.getOSCAWasteReminder()
    case .pushCategoryPressReleases:
      return self.userDefaults.isOSCAPressReleasesPushingNotification()
    case .pushCategoryConstructionSites:
      return self.userDefaults.isOSCAMapConstructionSitesPushingNotification()
    }// end switch case
  }// end func isPushing for key
  
  var isOnboardingComplete: Bool { return self.userDefaults.isOnboardingComplete }
  
  func setOnboardingCompleted() -> Void {
    self.userDefaults.isOnboardingComplete = true
  }// end func setOnboardingCompleted
}// end extension final class Launch
