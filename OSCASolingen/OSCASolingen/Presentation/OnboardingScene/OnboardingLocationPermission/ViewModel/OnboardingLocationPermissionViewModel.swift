//
//  OnboardingLocationPermissionViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 24.08.22.
//

import OSCAEssentials
import Foundation
import Combine

struct OnboardingLocationPermissionViewModelActions {
  let onPrevious: () -> Void
  let onNext: () -> Void
}

final class OnboardingLocationPermissionViewModel {
  
  private let data            : Onboarding
  private let actions         : OnboardingLocationPermissionViewModelActions?
  private var bindings        = Set<AnyCancellable>()
  private let locationManager = LocationManager.shared
  
  // MARK: Initializer
  init(data   : Onboarding,
       actions: OnboardingLocationPermissionViewModelActions) {
    self.data    = data
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  @Published private(set) var isLocationShared: Bool = false
  
  var grantLocationTitle: String {
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      return self.locationActivated
      
    case .restricted, .denied:
      return self.locationDeactivated
      
    default: return self.shareLocation
    }
  }
  
  let locationImage: String = "undraw_current_location_rypt-svg"
  
  // MARK: Localized Strings
  
  let title: String = NSLocalizedString(
    "onboarding_location_permission_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding location permission")
  let content: String = NSLocalizedString(
    "onboarding_location_permission_content",
    bundle: OSCASolingen.bundle,
    comment: "The content for onboarding location permission")
  let shareLocation: String = NSLocalizedString(
    "onboarding_location_permission_share",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding location permission button state share")
  let locationActivated: String = NSLocalizedString(
    "onboarding_location_permission_activated",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding location permission button state activated")
  let locationDeactivated: String = NSLocalizedString(
    "onboarding_location_permission_deactivated",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding location permission button state deactivated")
  let alertTitle: String = NSLocalizedString(
    "onboarding_location_permission_alert_title",
    bundle: OSCASolingen.bundle,
    comment: "The title for onboarding location permission alert")
  let alertMessage: String = NSLocalizedString(
    "onboarding_location_permission_alert_message",
    bundle: OSCASolingen.bundle,
    comment: "The message for onboarding location permission alert")
  
  // MARK: - Private
  
  @objc func didChangeAuthorization() {
    switch self.locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      self.isLocationShared = true
      
    case .restricted, .denied:
      self.isLocationShared = false
      
    default: break
    }
  }
}

// MARK: - INPUT. View event methods
extension OnboardingLocationPermissionViewModel {
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.didChangeAuthorization),
      name: .userLocationPermissionDidChange,
      object: nil)
    
    
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      self.isLocationShared = true
      
    case .restricted, .denied:
      self.isLocationShared = false
      
    default: break
    }
  }
  
  func grantButtonTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    DispatchQueue.main.async {
      self.locationManager.askForPermissionIfNeeded()
    }
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
