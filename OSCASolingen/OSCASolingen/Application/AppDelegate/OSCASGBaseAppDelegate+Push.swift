//
//  OSCASGBaseAppDelegate+Push.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 25.10.22.
//

import UIKit

// MARK: - Push notification
extension OSCASGBaseAppDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithPushOptions userInfo: [AnyHashable: Any]) -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let solingenAppFlow = appFlow else { return false }
    return solingenAppFlow.application(didFinishLaunchingWithPushOptions: userInfo)
  }// end func application did finish launching with push options
  
  /// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
  /// - Parameter application: The app object that initiated the remote-notification registration process.
  /// - Parameter deviceToken: A globally unique token that identifies this device to APNs. Send this token to the server that you use to generate remote notifications. Your server must pass this token unmodified back to APNs when sending those remote notifications. APNs device tokens are of variable length. **Do not hard-code their size.**
  open dynamic func application(_ application: UIApplication,
                                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let solingenAppFlow = appFlow else { return }
    solingenAppFlow.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  } // end application didRegisterForRemoteNotificationsWithDeviceToken
  
  open dynamic func application(_ application: UIApplication,
                                didFailToRegisterForRemoteNotificationsWithError error: Swift.Error) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
    print("Failed to register: \(error)")
#endif
    guard let solingenAppFlow = appFlow else { return }
    solingenAppFlow.delegate?.application(appFlow: solingenAppFlow,
                                          didFailToRegisterForRemoteNotificationsWithError: error)
  }// end application did fail to register for remote notifications with error
  
  ///
  open dynamic func application(_ application: UIApplication,
                                didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                                fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let solingenAppFlow = appFlow else { return }
    solingenAppFlow.delegate?.application(appFlow: solingenAppFlow,
                                          didReceiveRemoteNotification: userInfo,
                                          fetchCompletionHandler: completionHandler)
  }// end public func application did receive remote notification
}// end extension class OSCASGBaseAppDelegate

// MARK: - Push options
extension OSCASGBaseAppDelegate {
  /// Are there push options in the `launchOptions`?
  /// - parameter launchOptions: options `dict`
  func extractPushOptions(from launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> [AnyHashable: Any]? {
    guard let notificationOption = launchOptions?[.remoteNotification],
          let userInfo = notificationOption as? [AnyHashable: Any] else { return nil }
    return userInfo
  }// end private func extractPushOptions from launchOptions
}// end extension class OSCASGBaseAppDelegate
