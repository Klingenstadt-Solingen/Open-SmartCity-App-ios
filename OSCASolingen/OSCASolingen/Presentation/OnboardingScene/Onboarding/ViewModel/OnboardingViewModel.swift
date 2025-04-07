//
//  OnboardingViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import Foundation

struct OnboardingViewModelActions {
  let onNext: () -> Void
}

final class OnboardingViewModel {
  
  private let actions: OnboardingViewModelActions?
  
  // MARK: Initializer
  init(actions: OnboardingViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  let image: String = "placeholder_image"
  let title: String = "Klingenstadt"
  let subtitle: String = "Solingen"
  
  // MARK: Localized Strings
  
  let content: String = NSLocalizedString(
    "onboarding_content",
    bundle: OSCASolingen.bundle,
    comment: "The content for onboarding")
  
  // MARK: - Private
  
}

// MARK: - INPUT. View event methods
extension OnboardingViewModel {
  func viewDidLoad() {}
  
  func nextButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.actions?.onNext()
  }
}
