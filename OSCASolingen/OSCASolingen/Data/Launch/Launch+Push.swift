//
//  Launch+Push.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.02.24.
//

import Foundation
import OSCAEssentials
import UIKit
import NotificationCenter
import Combine

// MARK: - Push
extension Launch {
  func isRemoteNotificiationAllowed(with completion: @escaping (_ isAuthorized: Bool) -> Void) {
    UNUserNotificationCenter.current()
      .getNotificationSettings(){ [weak self] notificationSettings in
        guard let `self` = self else { return }
        let flag = notificationSettings.authorizationStatus == .authorized
        completion(flag)
      }// end completion closure
  }// end func isRemoteNotificiationAllowed with completion
  
  func registerForPushAsync() async -> Void {
    await UIApplication.shared
      .registerForRemoteNotifications()
    // continuation of register for remote notifications
    return
  }// end func registerForPushAuthorizationAsync
  
  /// request push authorization
  /// * `.badge`: display  number on the corner of the app's icon
  /// * `.sound`: play a sound
  /// * `.alert`: display a text notification
  /// * `.carPlay`: display notificatinos in CarPlay
  /// * `.providesAppNotificationSettings`: the app has its own UI for notification settings
  func requestPushAuthorizationAsyncThrows() async throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let authorizationGranted = try await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert,
                                      .sound,
                                      .badge,
                                      .providesAppNotificationSettings,
                                      .carPlay])
    // continuation of request authorization
    guard authorizationGranted else { return false }
    let criticalAuthorizationGranted = try await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.criticalAlert])
    // continuation of request critical authorization
    guard criticalAuthorizationGranted else { return false }
    return true
  }// end func requestPushAuthorizationAsyncThrows
  
  func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
#if DEBUG
    let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("\(String(describing: Self.self)): \(#function): tokenString: \(String(describing: deviceTokenString))")
#endif
    self.parseInstallation.processDeviceToken(deviceToken)
  }// end func application did register for Remote notification with device token
}// end extension final class Launch

// MARK: - register for notifications
extension Launch {
  func registerForRemoteNotificationsAsync() async {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let notificationSettings = await UNUserNotificationCenter.current()
      .notificationSettings()
    // continuation settings
    if ((notificationSettings.authorizationStatus == .authorized) ||
        (notificationSettings.authorizationStatus == .provisional)) {
      setAllCategories()
    }// end if
    await UIApplication.shared
      .registerForRemoteNotifications()
    // continuation register
  }// end public func registerForRemoteNotificationsAsync
}// end extension final class Launch

// MARK: - subscribe/unsubscribe
extension Launch {
  func subscribe(to key: Launch.Keys) -> InstallationPublisher {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.parseInstallation.subscribe(to: key)
    // network
    return syncInstallation()
  }// end func subscribe to key
  
  func unsubscribe(from key: Launch.Keys) -> InstallationPublisher {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.parseInstallation.unsubscribe(from: key)
    // then network
    return syncInstallation()
  }// end func unsubscribe from key
}// end extension final class Launch

// MARK: - Notification observer
extension Launch {
  func addNotificationObserver() -> Void {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.pushStateDidChange),
      name: .mapConstructionSitesPushDidChange,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.pushStateDidChange),
      name: .pressReleasesPushDidChange,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.pushStateDidChange),
      name: .wasteReminderDidChange,
      object: nil)
  }// end func addNotificationObserver
  
  func removeNotificationObserver() -> Void {
    NotificationCenter.default.removeObserver(
      self,
      name: .mapConstructionSitesPushDidChange,
      object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: .pressReleasesPushDidChange,
      object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: .wasteReminderDidChange,
      object: nil)
  }// end func removeNotificationObserver
  
  @objc
  func pushStateDidChange(_ notification: Notification) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if notification.name == NSNotification.Name.wasteReminderDidChange {
      self.pushStateChanged = Launch.Keys.pushCategoryWaste
    }// end if
    if notification.name == NSNotification.Name.pressReleasesPushDidChange {
      self.pushStateChanged = Launch.Keys.pushCategoryPressReleases
    }// end if
    if notification.name == NSNotification.Name.mapConstructionSitesPushDidChange {
      self.pushStateChanged = Launch.Keys.pushCategoryConstructionSites
    }// end if
  }// end @objc func pushStatedidChange for key
}// end extension final class Launch

// MARK: - notification categories
extension Launch {
  public static var notificationCategories: Set<UNNotificationCategory> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let options: UNNotificationCategoryOptions = [.allowInCarPlay]
    /* Disabled module Corona
     let coronaStatsCategory = makeCoronaStatsCategory(with: options)
     */
    let pressReleasesCategory = self.makePressReleasesCategory(with: options)
    let wasteCategory = self.makeWasteCategory(with: options)
    let constructionSitesCategory = self.makeConstructionSitesCategory(with: options)
    var setOfNotificationCategories: Set<UNNotificationCategory> = Set<UNNotificationCategory>()
    /* Disabled module Corona
     setOfNotificationCategories.insert(coronaStatsCategory)
     */
    setOfNotificationCategories.insert(pressReleasesCategory)
    setOfNotificationCategories.insert(wasteCategory)
    setOfNotificationCategories.insert(constructionSitesCategory)
    return setOfNotificationCategories
  }// end var notificationCategories
  
  private func setAllCategories() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter
      .setNotificationCategories(Launch.notificationCategories)
  } // end func setAllCategories
}// end extension final class Launch

// MARK: - PressReleases Notification
extension Launch {
  public static let pressReleasesIdentifier = "PRESS_RELEASE"
  private static func makePressReleasesCategory(with options: UNNotificationCategoryOptions) -> UNNotificationCategory {
    let openAction = UNNotificationAction(identifier: "OPEN_PR",
                                          title: "Ansehen",
                                          options: .foreground)
    return UNNotificationCategory(identifier: Self.pressReleasesIdentifier,
                                  actions: [openAction],
                                  intentIdentifiers: [],
                                  hiddenPreviewsBodyPlaceholder: "Neue Pressemitteilung",
                                  categorySummaryFormat: "%u weitere Pressemitteilungen",
                                  options: options)
  }// end private static func makePressReleasesCategory
}// end extension final class Launch

// MARK: - Waste Notification
extension Launch {
  public static let wasteIdentifier = "WASTE_INFO"
  private static func makeWasteCategory(with options: UNNotificationCategoryOptions) -> UNNotificationCategory {
    let openAction = UNNotificationAction(identifier: "OPEN_WASTE",
                                          title: "Ansehen",
                                          options: .foreground)
    return UNNotificationCategory(identifier: Self.wasteIdentifier,
                                  actions: [openAction],
                                  intentIdentifiers: [],
                                  hiddenPreviewsBodyPlaceholder: "Abfallabfuhr Hinweis",
                                  categorySummaryFormat: "%u weitere Abfallabfuhr Termine",
                                  options: options)
  }// end private static func makeWasteCategory
}// end extension final class Launch

// MARK: - Construction Sites Notification
extension Launch {
  public static let constructionSitesIdentifier = "CONSTRUCTION_INFO"
  private static func makeConstructionSitesCategory(with options: UNNotificationCategoryOptions) -> UNNotificationCategory {
    UNNotificationCategory(identifier: Self.constructionSitesIdentifier,
                           actions: [],
                           intentIdentifiers: [],
                           hiddenPreviewsBodyPlaceholder: "Neue Baustelle",
                           categorySummaryFormat: "%u weitere Baustellen",
                           options: options)
  }// end private static func makeConstructionSitesCategory
}// end extension final class Launch

extension Launch {
  /// push category keys
  enum Keys: String {
    case pushCategoryConstructionSites = "baustellen-ios"
    /* Disabled module Corona
     case pushCategoryCoronaStats = "coronastats-ios"
     */
    case pushCategoryPressReleases = "meldungen-ios"
    case pushCategoryWaste = "abfall-ios"
  }// end enum Keys
}// end extension final class Launch
