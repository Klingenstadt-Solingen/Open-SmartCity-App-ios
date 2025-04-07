//
//  OnboardingFlow.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//  Reviewed by Stephan Breidenbach on 19.09.22.
//

import OSCAEssentials
import UIKit

protocol OnboardingFlowDependencies {
  func makeOnboardingViewController(actions: OnboardingViewModelActions) -> OnboardingViewController
  func makeOnboardingPrivacyAdviceViewController(actions: OnboardingPrivacyAdviceViewModelActions) -> OnboardingPrivacyAdviceViewController
  func makeOnboardingPrivacyPolicyViewController(actions: OnboardingPrivacyPolicyViewModelActions) -> OnboardingPrivacyPolicyViewController
  func makeOnboardingNotificationViewController(actions: OnboardingNotificationViewModelActions) -> OnboardingNotificationViewController
  func makeOnboardingLocationPermissionViewController(actions: OnboardingLocationPermissionViewModelActions) -> OnboardingLocationPermissionViewController
  func makeOnboardingLastViewController(actions: OnboardingLastViewModelActions) -> OnboardingLastViewController
  var appFlow: SolingenAppFlow? { get }
} // end protocol OnboardingFlowDependencies

final class OnboardingFlow: NSObject {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  
  /**
   router injected via initializer: `router`will be used to push and pop view controllers
   */
  var router: Router
  var onboardingCompletion: () -> Void
  /**
   dependencies injected via initializer DI conforming to the `OnboardingFlowDependencies` protocol
   */
  private let dependencies: OnboardingFlowDependencies
  
  private var onDismissed: (() -> Void)? = nil
  private var animated: Bool = false
  
  /**
   `weak`reference to `OnboardingViewController` instance
   */
  private weak var onboardingViewController: OnboardingViewController?
  /**
   `weak`reference to `OnboardingPrivacyAdviceViewController` instance
   */
  private weak var onboardingPrivacyAdviceViewController: OnboardingPrivacyAdviceViewController?
  /**
   `weak`reference to `OnboardingPrivacyPolicyViewController` instance
   */
  private weak var onboardingPrivacyPolicyViewController: OnboardingPrivacyPolicyViewController?
  /**
   `weak`reference to `OnboardingNotificationViewController` instance
   */
  private weak var onboardingNotificationViewController: OnboardingNotificationViewController?
  /**
   `weak`reference to `OnboardingLocationPermissionViewController` instance
   */
  private weak var onboardingLocationPermissionViewController: OnboardingLocationPermissionViewController?
  /**
   `weak`reference to `OnboardingLastViewController` instance
   */
  private weak var onboardingLastViewController: OnboardingLastViewController?
  
  init(router: Router,
       onboardingCompletion: @escaping () -> Void,
       dependencies: OnboardingFlowDependencies) {
    self.router = router
    self.onboardingCompletion = onboardingCompletion
    self.dependencies = dependencies
  } // end init
  
  private func showFirstView(animated: Bool, onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.onDismissed = onDismissed
    self.animated = animated
    
    if let vc = onboardingViewController {
      router.present(vc, animated: true)
    } else {
      let actions = OnboardingViewModelActions(
        onNext: showPrivacyAdvice
      )
      // instantiate onboarding view controller
      let vc = dependencies.makeOnboardingViewController(actions: actions)
      router.present(vc,
                     animated: animated,
                     onDismissed: onDismissed)
      onboardingViewController = vc
    } // end if
  } // end private func showFirstView
  
  func present(animated: Bool, onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
    showFirstView(animated: animated,
                  onDismissed: onDismissed)
  } // end func present
} // end final class OnboardingFlow

extension OnboardingFlow: Coordinator {}

// MARK: Onboarding Actions

extension OnboardingFlow {
  private func showPrivacyAdvice() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let vc = onboardingPrivacyAdviceViewController {
      router.present(vc, animated: true)
    } else {
      let actions = OnboardingPrivacyAdviceViewModelActions(
        onPrevious: {
          self.router.navigateBack(animated: true)
        },
        onNext: showPrivacyPolicy
      )
      let vc = dependencies.makeOnboardingPrivacyAdviceViewController(actions: actions)
      router.present(vc,
                     animated: true)
      onboardingPrivacyAdviceViewController = vc
    } // end if
  } // end private func showPrivacyAdvice
} // end extension final class OnboardingFlow

// MARK: Onboarding Privacy Advice Actions

extension OnboardingFlow {
  private func showPrivacyPolicy() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let vc = onboardingPrivacyPolicyViewController {
      router.present(vc, animated: true)
    } else {
      let actions = OnboardingPrivacyPolicyViewModelActions(
        onPrevious: {
          self.router.navigateBack(animated: true)
        },
        onNext: showNotification
      )
      let vc = dependencies.makeOnboardingPrivacyPolicyViewController(actions: actions)
      router.present(vc,
                     animated: true)
      onboardingPrivacyPolicyViewController = vc
    } // end if
  } // end func showPrivacyPolicy
} // end extension final class OnboardingFlow

// MARK: Onboarding Privacy Policy Actions

extension OnboardingFlow {
  private func showNotification() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let vc = onboardingNotificationViewController {
      router.present(vc,
                     animated: true)
    } else {
      let actions = OnboardingNotificationViewModelActions(
        onNext: showLocationPermission,
        onPrevious: {
          self.router.navigateBack(animated: true)
        },
        requestPushAuthorizationAsyncThrows: requestPushAuthorizationAsyncThrows
      )
      let vc = dependencies.makeOnboardingNotificationViewController(actions: actions)
      router.present(vc,
                     animated: true)
      onboardingNotificationViewController = vc
    } // end if
  } // end func showNotification
} // end extension final class OnboardingFlow

// MARK: Onboarding Notification Actions

extension OnboardingFlow {
  private func showLocationPermission() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let vc = onboardingLocationPermissionViewController {
      router.present(vc, animated: true)
    } else {
      let actions = OnboardingLocationPermissionViewModelActions(
        onPrevious: {
          self.router.navigateBack(animated: true)
        },
        onNext: showLast
      )
      let vc = dependencies.makeOnboardingLocationPermissionViewController(actions: actions)
      router.present(vc, animated: true)
      onboardingLocationPermissionViewController = vc
    } // end if
  } // end func showLocationPermission
  
  
  private func requestPushAuthorizationAsyncThrows() async throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let appFlow = self.dependencies.appFlow else { throw OSCASGError.appInit(msg: "corrupt app flow") }
    return try await appFlow.requestPushAuthorizationAsyncThrows()
  }// end private func requestPushAuthorizationAsync
} // end extension final class OnboardingFlow

// MARK: Onboading Locations Permission Actions
extension OnboardingFlow {
  private func showLast() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let onboardingLastViewController = onboardingLastViewController {
      router.present(onboardingLastViewController,
                     animated: true)
    } else {
      let actions = OnboardingLastViewModelActions(
        onPrevious: {
          self.router.navigateBack(animated: true)
        },
        onNext: completeOnboarding
      )
      let vc = dependencies.makeOnboardingLastViewController(actions: actions)
      router.present(vc,
                     animated: true)
      onboardingLastViewController = vc
    } // end if
  } // end func showLast
} // end extension final class OnboardingFlow

// MARK: Onboarding Last Actions

extension OnboardingFlow {
  private func completeOnboarding() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let _ = onboardingLastViewController
    else { return }
    onboardingCompletion()
  } // end private func completeOnboarding
} // end extension final class OnboardingFlow

