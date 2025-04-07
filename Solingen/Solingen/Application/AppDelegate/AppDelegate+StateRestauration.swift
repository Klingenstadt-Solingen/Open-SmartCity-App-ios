//
//  AppDelegate+StateRestauration.swift
//  Solingen
//
//  Created by Stephan Breidenbach on 25.10.22.
//

import UIKit

// MARK: - state restauration
extension AppDelegate {
  override func application(_ application: UIApplication,
                            shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
    return super.application(application,
                             shouldSaveSecureApplicationState: coder)
  }// end func application should save secure application state
  
  override func application(_ application: UIApplication,
                            shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
    return super.application(application,
                             shouldRestoreSecureApplicationState: coder)
  }// end func application should restore secure application state
}// end extension class AppDelegate
