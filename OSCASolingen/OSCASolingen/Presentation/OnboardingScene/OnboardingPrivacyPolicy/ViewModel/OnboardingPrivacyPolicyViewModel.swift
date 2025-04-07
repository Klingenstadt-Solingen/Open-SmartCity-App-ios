//
//  OnboardingPrivacyPolicyViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import OSCAEssentials
import Foundation
import Combine

struct OnboardingPrivacyPolicyViewModelActions {
  let onPrevious: () -> Void
  let onNext: () -> Void
}

enum OnboardingPrivacyPolicyViewModelError: Error, Equatable {
  case privacyFetch
}

enum OnboardingPrivacyPolicyViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(OSCASGError)
}

final class OnboardingPrivacyPolicyViewModel {
  
  private let data     : Onboarding
  private let actions  : OnboardingPrivacyPolicyViewModelActions?
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  init(data   : Onboarding,
       actions: OnboardingPrivacyPolicyViewModelActions) {
    self.data    = data
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  @Published private(set) var state: OnboardingPrivacyPolicyViewModelState = .loading
  @Published private(set) var privacy: NSAttributedString? = nil
  
  // MARK: Localized Strings
  
  let title: String = NSLocalizedString(
    "onboarding_privacy_policy_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding privacy policy")
  
  // MARK: - Private
  
  private func getPrivacyText() {
    data.fetchAllParseConfigParams()
      .sink { completion in
        switch completion {
        case .finished:
          print("\(#function) - finished")
          if self.state != .finishedLoading { self.state = .finishedLoading }
          
        case .failure(let error):
          print("\(#function) - failure")
          if self.state == .loading { self.state = .error(error) }
        }
        
      } receiveValue: { fetchedConfig in
        guard let privacy = fetchedConfig.privacyText else { return }
        self.privacy = try? NSMutableAttributedString(HTMLString: privacy)
      }
      .store(in: &bindings)
  }
}

// MARK: - INPUT. View event methods
extension OnboardingPrivacyPolicyViewModel {
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.getPrivacyText()
  }
  
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
