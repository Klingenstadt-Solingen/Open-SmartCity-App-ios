//
//  SettingsFlow.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 20.06.22.
//  Reviewed by Stephan Breidenbach on 02.09.22.
//  Reviewed by Stephan Breidenbach on 09.09.22.
//

import OSCAEssentials
import OSCAWasteUI
import UIKit

protocol SettingsFlowDependencies {
  var deeplinkScheme: String { get }
  func makeDeeplinkPrefixes() -> [String]
  func makeSettingsViewController(actions: SettingsViewModelActions) -> SettingsViewController
  func makeOSCAWeatherStationSelectionCoordinator(router: Router) -> Coordinator
  func makeOSCAWasteSetupCoordinator(router: Router) -> Coordinator
  func makeLegallyViewController(actions: LegallyViewModelActions, screenTitle: String, text: String) -> LegallyViewController
}// end protocol SettingsFlowDependencies

/**
 The concrete coordinator implements the coordinator protocol. It knows how to create concrete view controllers and the order in which view controllers should be displayed.
 */
final class SettingsFlow: Coordinator {
  /// list of `Coordinator`s
  var children: [Coordinator] = []
  
  /// router injected via initializer: `router`will be used to push and pop view controllers
  var router: Router
  
  let dependencies: SettingsFlowDependencies
  
  /// Settings view controller instance
  private weak var settingsVC: SettingsViewController?
  /// Legally view controller instance
  private weak var imprintVC: LegallyViewController?
  /// Legally view controller instance
  private weak var privacyVC: LegallyViewController?
  
  init(router: Router,
       dependencies: SettingsFlowDependencies) {
    self.router = router
    self.dependencies = dependencies
  } // end init
  
  private func showWeatherStations() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = dependencies
      .makeOSCAWeatherStationSelectionCoordinator(router: router)
    presentChild(flow, animated: true)
  }
  
  private func showWasteAddressPicker() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = dependencies
      .makeOSCAWasteSetupCoordinator(router: router)
    presentChild(flow, animated: true)
  }// end private func showWasteAddressPicker
  
  private func showImprint(screenTitle: String, text: String) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let actions = LegallyViewModelActions()
    let vc = dependencies.makeLegallyViewController(
      actions: actions,
      screenTitle: screenTitle,
      text: text)
    let nav = UINavigationController(rootViewController: vc)
    self.router.presentModalViewController(
      nav,
      animated: true)
    self.imprintVC = vc
  }
  
  private func showPrivacy(screenTitle: String, text: String) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let actions = LegallyViewModelActions()
    let vc = dependencies.makeLegallyViewController(
      actions: actions,
      screenTitle: screenTitle,
      text: text)
    let nav = UINavigationController(rootViewController: vc)
    self.router.presentModalViewController(
      nav,
      animated: true)
    self.privacyVC = vc
  }
  
  func showSettingsMain(animated: Bool,
                        onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let settingsMainVC = settingsVC {
      router.present(settingsMainVC,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      let settingsViewControllerActions = SettingsViewModelActions(
        showWeatherStations   : self.showWeatherStations,
        showWasteAddressPicker: self.showWasteAddressPicker,
        showImprint           : self.showImprint,
        showPrivacy           : self.showPrivacy)
      
      /// instantiate view controller with view model actions
      let settingsViewController: SettingsViewController = dependencies.makeSettingsViewController(actions: settingsViewControllerActions)
      /// present view controller
      router.present(settingsViewController,
                     animated: animated,
                     onDismissed: onDismissed)
      /// local handle to the presenting `CityViewController` instance
      settingsVC = settingsViewController
    }// end if
  }// end func showSettingsMain
  /// present Settings view controller method
  /// * instantiate view model actions
  /// * instantiate view controller with view model actions
  /// * present view controller
  ///
  func present(animated: Bool,
               onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    showSettingsMain(animated: animated,
                     onDismissed: onDismissed)
  } // end func present
} // end final class SettingsFlow

extension SettingsFlow {
  /**
   add `child` `Coordinator`to `children` list of `Coordinator`s and present `child` `Coordinator`
   */
  public func presentChild(_ child: Coordinator,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    children.append(child)
    child.present(animated: animated) { [weak self, weak child] in
      guard let self = self, let child = child else { return }
      self.removeChild(child)
      onDismissed?()
    } // end on dismissed closure
  } // end public func presentChild
  
  private func removeChild(_ child: Coordinator) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// `children` includes `child`!!
    guard let index = children.firstIndex(where: { $0 === child }) else { return } // end guard
    children.remove(at: index)
  } // end private func removeChild
} // end extension public final class SettingsFlow
