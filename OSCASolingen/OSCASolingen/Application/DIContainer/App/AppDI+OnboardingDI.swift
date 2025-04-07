//
//  AppDI+OnboardingDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import UIKit

extension AppDI {
  final class OnboardingDI: OnboardingFlowDependencies {
    struct Dependencies {
      let appDI: AppDI
      let deeplinkScheme: String
    }

    private let dependencies: OnboardingDI.Dependencies

    var onboardingFlow: OnboardingFlow?
    var appFlow: SolingenAppFlow?

    init(dependencies: OnboardingDI.Dependencies) {
      self.dependencies = dependencies
      self.appFlow = dependencies.appDI.appFlowDI?.appFlow
    }

    // MARK: - Dependencies

    func makeOnboardingData() -> Onboarding {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#if DEBUG
      let networkService = dependencies.appDI.devNetworkService
#else
      let networkService = dependencies.appDI.productionNetworkService
#endif
      let dataDependencies = Onboarding.Dependencies(
        networkService: networkService,
        userDefaults: dependencies.appDI.userDefaults)
      return Onboarding(dependencies: dataDependencies)
    }

    // MARK: - Onboarding
    func makeOnboardingViewController(actions: OnboardingViewModelActions) -> OnboardingViewController {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingViewController.create(with: makeOnboardingViewModel(actions: actions))
    }

    func makeOnboardingViewModel(actions: OnboardingViewModelActions) -> OnboardingViewModel {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingViewModel(actions: actions)
    }

    // MARK: - Onboarding Privacy Advice

    func makeOnboardingPrivacyAdviceViewController(actions: OnboardingPrivacyAdviceViewModelActions) -> OnboardingPrivacyAdviceViewController {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingPrivacyAdviceViewController.create(with: makeOnboardingPrivacyAdviceViewModel(actions: actions))
    }

    func makeOnboardingPrivacyAdviceViewModel(actions: OnboardingPrivacyAdviceViewModelActions) -> OnboardingPrivacyAdviceViewModel {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingPrivacyAdviceViewModel(actions: actions)
    }

    // MARK: - Onboarding Privacy Policy

    func makeOnboardingPrivacyPolicyViewController(actions: OnboardingPrivacyPolicyViewModelActions) -> OnboardingPrivacyPolicyViewController {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingPrivacyPolicyViewController.create(with: makeOnboardingPrivacyPolicyViewModel(actions: actions))
    }

    func makeOnboardingPrivacyPolicyViewModel(actions: OnboardingPrivacyPolicyViewModelActions) -> OnboardingPrivacyPolicyViewModel {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingPrivacyPolicyViewModel(data: makeOnboardingData(), actions: actions)
    }

    // MARK: - Onboarding Notification

    func makeOnboardingNotificationViewController(actions: OnboardingNotificationViewModelActions) -> OnboardingNotificationViewController {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingNotificationViewController.create(with: makeOnboardingNotificationViewModel(actions: actions))
    }

    func makeOnboardingNotificationViewModel(actions: OnboardingNotificationViewModelActions) -> OnboardingNotificationViewModel {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingNotificationViewModel(data: makeOnboardingData(), actions: actions)
    }

    // MARK: - Onboarding Location Permission

    func makeOnboardingLocationPermissionViewController(actions: OnboardingLocationPermissionViewModelActions) -> OnboardingLocationPermissionViewController {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingLocationPermissionViewController.create(with: makeOnboardingLocationPermissionViewModel(actions: actions))
    }

    func makeOnboardingLocationPermissionViewModel(actions: OnboardingLocationPermissionViewModelActions) -> OnboardingLocationPermissionViewModel {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingLocationPermissionViewModel(data: makeOnboardingData(), actions: actions)
    }

    // MARK: - Onboarding Last

    func makeOnboardingLastViewController(actions: OnboardingLastViewModelActions) -> OnboardingLastViewController {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingLastViewController.create(with: makeOnboardingLastViewModel(actions: actions))
    }

    func makeOnboardingLastViewModel(actions: OnboardingLastViewModelActions) -> OnboardingLastViewModel {
      #if DEBUG
        print("\(String(describing: self)): \(#function)")
      #endif
      return OnboardingLastViewModel(actions: actions)
    }
  }
} // end extension public final class AppDI

// MARK: - Flow Coordinators

extension AppDI.OnboardingDI {
  /// singleton `OnboardingFlow`
  func makeOnboardingFlowCoordinator(router: Router,
                                     onboardingCompletion: @escaping () -> Void) -> OnboardingFlow {
    #if DEBUG
      print("\(String(describing: self)): \(#function)")
    #endif
    if let onboardingFlow = onboardingFlow {
      return onboardingFlow
    } else {
      let flow = OnboardingFlow(router: router,
                                onboardingCompletion: onboardingCompletion,
                                dependencies: self)
      onboardingFlow = flow
      return flow
    } // end if
  } // end func makeOnboardingFlowCoordinator
} // end extension final class OnboardingDI
