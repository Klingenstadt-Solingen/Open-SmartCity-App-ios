//
//  OnboardingPrivacyAdviceViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import Foundation

struct OnboardingPrivacyAdviceViewModelActions {
  let onPrevious: () -> Void
  let onNext: () -> Void
}

final class OnboardingPrivacyAdviceViewModel {
  
  private let actions: OnboardingPrivacyAdviceViewModelActions?
  
  // MARK: Initializer
  init(actions: OnboardingPrivacyAdviceViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  let image: String = "undraw_privacy_protection_nlwy-svg"
  
  // MARK: Localized Strings
  
  let title: String = NSLocalizedString(
    "onboarding_privacy_advice_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding privacy advice")
  let content: String = NSLocalizedString(
    "onboarding_privacy_advice_content",
    bundle: OSCASolingen.bundle,
    comment: "The content for onboarding privacy advice")
  
  // MARK: - Private
  
}

// MARK: - INPUT. View event methods
extension OnboardingPrivacyAdviceViewModel {
  func viewDidLoad() {}
  
  func nextButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.actions?.onNext()
  }
  
  func previousButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.actions?.onPrevious()
  }
}
