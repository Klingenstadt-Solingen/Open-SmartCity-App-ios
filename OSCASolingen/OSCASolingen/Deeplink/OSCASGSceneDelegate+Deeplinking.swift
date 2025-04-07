//
//  OSCASGSceneDelegate+Deeplinking.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit
import OSCAEssentials
import OSCAPressReleases
import OSCAMap
import OSCAWaste

// MARK: - Deeplinking
extension OSCASGSceneDelegate {
  /// handle `connectionOptions` for deeplinking
  /// - parameters connectionOptions: scene's connection options
  func handle(connectionOptions: UIScene.ConnectionOptions) throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    //either one will work
    // handleDeepLinkUrl(connectionOptions.urlContexts.first?.url)
    // handleDeepLinkUrl(connectionOptions.userActivities.first?.webpageURL)
    if let url = connectionOptions.urlContexts.first?.url {
#if DEBUG
      print("Deeplink: \(url.absoluteString)")
#endif
      guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "App flow") }
      return solingenAppFlow
        .handleURL(url,
                   onDismissed: solingenAppFlowOnDismissed)
    } else {
      if let url = connectionOptions.userActivities.first?.webpageURL {
#if DEBUG
        print("Deeplink: \(url.absoluteString)")
#endif
        guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "App flow") }
        return solingenAppFlow
          .handleURL(url,
                     onDismissed: solingenAppFlowOnDismissed)
      }// end if
    }// end if
    if let notificationResponse = connectionOptions.notificationResponse {
#if DEBUG
      print("Notification Response: \(notificationResponse.notification.description)")
#endif
      let notification = notificationResponse.notification
      let deliveryDate = notification.date
      let request = notification.request
      let content = request.content
      let title = content.title
      let subtitle = content.subtitle
      let body = content.body
      let description = content.description
      let userInfo = content.userInfo
      guard let objectId = userInfo["objectId"] as? String,
            let linkType = userInfo["linkType"] as? String,
            let deeplink = userInfo["deepLink"] as? String,
            let aps = userInfo["aps"] as? [AnyHashable : Any],
            let category = aps["category"] as? String else { return false }
      switch category {
      case Launch.pressReleasesIdentifier:
        NotificationCenter.default.post(name: .pressReleasesPushDidChange,
                                        object: nil,
                                        userInfo: userInfo)
        return true
      case Launch.constructionSitesIdentifier:
        NotificationCenter.default.post(name: .mapConstructionSitesPushDidChange,
                                        object: nil,
                                        userInfo: userInfo)
        return true
      case Launch.wasteIdentifier:
        NotificationCenter.default.post(name: .wasteReminderDidChange,
                                        object: nil,
                                        userInfo: userInfo)
        return true
      default:
        return false
      }// end switch case
    }// end if push
    return false
  }// end handle connection options
  
  func handle(openURLContexts urlContexts: Set<UIOpenURLContext>) throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // handleDeepLinkUrl(URLContexts.first?.url)
    if let url = urlContexts.first?.url {
#if DEBUG
      print("Deeplink: \(url.absoluteString)")
#endif
      guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "App flow") }
      return solingenAppFlow
        .handleURL(url,
                   onDismissed: solingenAppFlowOnDismissed)
    } else {
#if DEBUG
      print("No well formed Deeplink!")
#endif
      return false
    }// end if
  }// end private func handle
  
  func handle(continue userActivity: NSUserActivity) throws -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // handleDeepLinkUrl(userActivity.webpageURL)
    if let url = userActivity.webpageURL {
#if DEBUG
      print("Deeplink: \(url.absoluteString)")
#endif
      guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "App flow") }
      return solingenAppFlow
        .handleURL(url,
                   onDismissed: solingenAppFlowOnDismissed)
    } else {
#if DEBUG
      print("No well formed Deeplink!")
#endif
      return false
    }// end if
  }// end private func handle continue user activity
  
  /// First launch after install
  /// ```console
  ///  xcrun simctl openurl booted \
  ///    "solingen://deeplinkNavigation"
  /// ```
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Void {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    do {
      //first launch after install
      if try !handle(openURLContexts: URLContexts) {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
        guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "app flow") }
        solingenAppFlow
          .present(animated: true,
                   onDismissed: solingenAppFlowOnDismissed)
      }// end if
    } catch let error {
      let retryHandler: () -> Void = {[weak self] in
        guard let `self` = self else { return }
        self.scene(scene,
                   openURLContexts: URLContexts)
      }// end retry handler
      if let oscaSGError = error as? OSCASGError {
        
        handle(oscaSGError,
               retryHandler: retryHandler)
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "unknown")
        handle(oscaSGError,
               retryHandler: retryHandler)
      }// end if
    }// end do catch
  }// end func scene open url contexts
  
  /// When in background mode
  /// ```console
  /// xcrun simctl openurl booted \
  ///   "solingen://deeplinkNavigation"
  /// ```
  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Void {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    do {
      //when in background mode
      if try !handle(continue: userActivity) {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
        guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "app flow") }
        solingenAppFlow
          .present(animated: true,
                   onDismissed: solingenAppFlowOnDismissed)
      }// end if
    } catch let error {
      let retryHandler: () -> Void = {[weak self] in
        guard let `self` = self else { return }
        self.scene(scene,
                   continue: userActivity)
      }// end retry handler
      if let oscaSGError = error as? OSCASGError {
        
        handle(oscaSGError,
               retryHandler: retryHandler)
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "unknown")
        handle(oscaSGError,
               retryHandler: retryHandler)
      }// end if
    }// end do catch
  }// end func scene continue
}// end extension class OSCASGSceneDelegate
