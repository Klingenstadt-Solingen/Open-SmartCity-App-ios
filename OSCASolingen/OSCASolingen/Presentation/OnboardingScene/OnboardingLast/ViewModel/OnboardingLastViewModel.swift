//
//  OnboardingLastViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 24.08.22.
//

import OSCAEssentials
import Foundation

struct OnboardingLastViewModelActions {
  let onPrevious: () -> Void
  let onNext: () -> Void
}

final class OnboardingLastViewModel {
  
  private let actions: OnboardingLastViewModelActions?
  
  // MARK: Initializer
  init(actions: OnboardingLastViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  let startImage: String = "undraw_welcoming_xvuq-svg"
  
  // MARK: Localized Strings
  
  let title: String = NSLocalizedString(
    "onboarding_last_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding last")
  let content: String = NSLocalizedString(
    "onboarding_last_content",
    bundle: OSCASolingen.bundle,
    comment: "The content for onboarding last")
  let startTitle: String = NSLocalizedString(
    "onboarding_last_start_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding last start button")
  
  // MARK: - Private
  
  
}

// MARK: - INPUT. View event methods
extension OnboardingLastViewModel {
  func viewDidLoad() {}
  
  func startButtonTouch() {
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
