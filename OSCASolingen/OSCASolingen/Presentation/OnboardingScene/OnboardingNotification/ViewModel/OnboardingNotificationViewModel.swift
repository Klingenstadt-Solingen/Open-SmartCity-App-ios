//
//  OnboardingNotificationViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 24.08.22.
//  Reviewed by Stephan Breidenbach on 27.10.22
//

import Combine
import Foundation
import OSCAEssentials

struct OnboardingNotificationViewModelActions {
  let onNext: () -> Void
  let onPrevious: () -> Void
  let requestPushAuthorizationAsyncThrows: () async throws -> Bool
}// end struct OnboardingNotificationViewModelActions

final class OnboardingNotificationViewModel {
  private let data: Onboarding
  private let actions: OnboardingNotificationViewModelActions?
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  
  init(data: Onboarding,
       actions: OnboardingNotificationViewModelActions) {
    self.data = data
    self.actions = actions
  }// end init
  
  // MARK: - OUTPUT
  @Published private(set) var isNotificationGranted: Bool = false
  
  var activatedNotificationTitle: String {
    isNotificationGranted ? notificationActivated : notificationDeactivated
  }// end var activatedNotificationTitle
  
  var grantNotificationTitle: String { allowNotification }
  
  let notificationImage: String = "undraw_my_notifications_rjej-svg"
  
  // MARK: Localized Strings
  
  let title: String = NSLocalizedString(
    "onboarding_notification_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding notification")
  let content: String = NSLocalizedString(
    "onboarding_notification_content",
    bundle: OSCASolingen.bundle,
    comment: "The content for onboarding notification")
  let allowNotification: String = NSLocalizedString(
    "onboarding_notification_allow",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding notification button state allow")
  let notificationActivated: String = NSLocalizedString(
    "onboarding_notification_activated",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding notification button state activated")
  let notificationDeactivated: String = NSLocalizedString(
    "onboarding_notification_deactivated",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding notification button state deactivated")
  
  // MARK: - Private
}// end final class OnboardingNotificationViewModel

// MARK: - INPUT. View event methods

extension OnboardingNotificationViewModel {
  func viewDidLoad() {}
  
  private func requestPushAuthorizationAsyncThrows() async throws {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let actions = actions else { return }
    let requestTask = Task {() -> Bool in
      let granted = try await actions
        .requestPushAuthorizationAsyncThrows()
      return granted
    }// end let
    let granted = try await requestTask.result.get()
    // continuation
    self.isNotificationGranted = granted
  }// end private func requestPushAuthorization
  
  func grantButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    Task {
      try await requestPushAuthorizationAsyncThrows()
    }// end Task
  }// end func grantButtonTouch
  
  func nextButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let actions = actions else { return }
    actions.onNext()
  }// end func nextButtonTouch
  
  func previousButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let actions = actions else { return }
    actions.onPrevious()
  }// end func previousButtonTouch
}// end extension final class OnboardingNotificationViewModel
