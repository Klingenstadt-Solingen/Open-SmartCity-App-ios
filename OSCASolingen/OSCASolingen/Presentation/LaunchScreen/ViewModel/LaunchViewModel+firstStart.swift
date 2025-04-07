//
//  LaunchViewModel+firstStart.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.02.24.
//

import Foundation
import OSCAEssentials
import OSCANetworkService
import Combine

extension LaunchViewModel {
  func firstStart() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // parse user logged in?
    if !self.isLoggedIn { loginParse(); return }
    // parse installation in sync with parse backend?
    if !self.isInstallationSynced { syncInstallation(); return }
    // is the onboarding completed?
    if !self.isOnboardingComplete {
      // show onboarding
      self.state = .showOnboarding
      return
    }// end if
    // are notifications allowed?
    if let isNotificationAllowed = self.isNotificationAllowed {
      if !isNotificationAllowed {
        self.showMain()
      } else {
        // is push registered?
        if let pushRegistered = self.pushRegistered,
           pushRegistered {
          self.showMain()
        } else {
          registerForPush()
          return
        }// end if
      }// end if
    } else {
      isRemoteNotificationAllowed(){[weak self] isAuthorized in
        guard let `self` = self else { return }
        self.isNotificationAllowed = isAuthorized
        self.state = .firstStart
      }// end completion closure
      return
    }// end if
  }// end func firstStart
  
  func isRemoteNotificationAllowed(with completion: @escaping (_ isAuthorized: Bool) -> Void) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if state != .loading { state = .loading }
    self.data.isRemoteNotificiationAllowed(with: completion)
  }// end func isRemoteNotificationAllowed with completion
}// end extension final class LaunchViewModel
