//
//  LaunchViewController+AppFlowDelegate.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.02.24.
//

import OSCAEssentials
import UIKit

// MARK: - solingen App flow Delegate
extension LaunchViewController: SolingenAppFlowDelegate {
  
  
  func setupSolingenAppFlowDelegate() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.solingenAppFlow.delegate = self
  }// end func setupSolingenAppFlowDelegate
  
  func registerForPushAsync(appFlow: SolingenAppFlow) async -> Void {
    guard let delegate = appFlow.delegate,
          delegate === self else { return }
    viewModel.registerForPush()
  }// end func registerForPushAuthorizationAsync
  
  func application(appFlow: SolingenAppFlow,
                   didFinishLaunchingWithPushOptions userInfo: [AnyHashable : Any]) -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = appFlow.delegate,
          delegate === self else { return false }
    guard let aps = userInfo["aps"] as? [String: AnyObject] else {
      return false
    }// end guard
#if DEBUG
    print("aps: \(aps)")
#endif
#warning("TODO: implementation")
    return true
  }// end func application did finish launching with push options with user info
  
  func application(appFlow: SolingenAppFlow,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = appFlow.delegate,
          delegate === self else { return }
    
    viewModel.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }// end func application did register for remote notifications with device token
  
  func application(appFlow: SolingenAppFlow,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = appFlow.delegate,
          delegate === self else { return }
    viewModel.application(didFailToRegisterForRemoteNotificationsWithError: error)
  }// end func application did fail to register for remote notifications with error
  
  func application(appFlow: SolingenAppFlow,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = appFlow.delegate,
          delegate === self else { return }
    
    guard let aps = userInfo["aps"] as? [String: AnyObject] else {
      completionHandler(.failed)
      return
    }// end guard
#if DEBUG
    print("aps: \(aps)")
#endif
#warning("TODO: implementation")
    completionHandler(.noData)
  }// end func application did receive remote notification with fetch completion handle
  
  func onboardingCompleted(appFlow: SolingenAppFlow) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = appFlow.delegate,
          delegate === self else { return }
    viewModel.onboardingCompleted()
  }// end func onboardingCompleted
  
  func requestPushAuthorizationAsyncThrows(appFLow: SolingenAppFlow) async throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = appFLow.delegate,
          delegate === self else { return false }
    return try await viewModel.requestPushAuthorizationAsyncThrows()
  }// end func requestPushAuthorizationAsync
}// end extension final class LaunchViewController

