//
//  AppDelegate+Push.swift
//  Solingen
//
//  Created by Stephan Breidenbach on 25.10.22.
//

import UIKit
// MARK: - Push notifications
extension AppDelegate {
  /// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
  /// - Parameter application: The app object that initiated the remote-notification registration process.
  /// - Parameter deviceToken: A globally unique token that identifies this device to APNs. Send this token to the server that you use to generate remote notifications. Your server must pass this token unmodified back to APNs when sending those remote notifications. APNs device tokens are of variable length. **Do not hard-code their size.**
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  } // end application didRegisterForRemoteNotificationsWithDeviceToken

  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }// end application did fail to register for remote notifications with error


  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.application(application,
                      didReceiveRemoteNotification: userInfo,
                      fetchCompletionHandler: completionHandler)
  }// end application did receive remote notification with fetch completion handler

    // Handle Foreground Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }

    // On click of notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let url = userInfo["deepLink"] as? String {
            if let deepLink = URL(string: url) {
                if UIApplication.shared.canOpenURL(deepLink) {
                    UIApplication.shared.open(deepLink, options: [:], completionHandler: nil)
                }
            }
        }
    }
}// end extension class AppDelegate
