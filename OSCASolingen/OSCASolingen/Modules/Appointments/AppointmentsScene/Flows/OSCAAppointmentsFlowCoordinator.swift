//
//  OSCAAppointmentsFlowCoordinator.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 20.02.23.
//

import OSCAEssentials
import OSCASafariView
// After seperating from core app import OSCAAppointments
import Foundation

public protocol OSCAAppointmentsFlowCoordinatorDependencies {
  var deeplinkScheme: String { get }
  func makeOSCAAppointmentsViewController(actions: OSCAAppointmentsViewModel.Actions) -> OSCAAppointmentsViewController
  func makeSafariViewFlowCoordinator(router: Router, url: URL) -> OSCASafariViewFlowCoordinator
}

public final class OSCAAppointmentsFlowCoordinator: NSObject, Coordinator {
  
  public init(router: Router,
              dependencies: OSCAAppointmentsFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }
  
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`s
   */
  public var children: [Coordinator] = []
  /**
   router injected via initializer: `router` will be used to push and pop view controllers
   */
  public var router: Router
  /**
   dependencies injected via initializer DI conforming to the `OSCAAppointmentsFlowCoordinatorDependencies` protocol
   */
  let dependencies: OSCAAppointmentsFlowCoordinatorDependencies
  
  private weak var appointmentsVC: OSCAAppointmentsViewController?
  private weak var webViewFlow: Coordinator?
  
  // MARK: Appointments SafariView
  private func showSafariView(_ url: URL) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let webViewFlow = self.webViewFlow {
      self.removeChild(webViewFlow)
      self.webViewFlow = nil
    }
    let flow = self.dependencies.makeSafariViewFlowCoordinator(
      router: self.router,
      url: url)
    self.presentChild(flow,
                      animated: true) {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
    }
    self.webViewFlow = flow
  }
  
  // MARK: Appointments
  func showAppointments(animated: Bool, onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
    let actions = OSCAAppointmentsViewModel.Actions(
      showSafariView: self.showSafariView)
    
    let viewController = self.dependencies.makeOSCAAppointmentsViewController(actions: actions)
    
    self.router.present(
      viewController,
      animated: animated,
      onDismissed: onDismissed
    )
    self.appointmentsVC = viewController
  }
}

extension OSCAAppointmentsFlowCoordinator {
  public func present(animated: Bool, onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.showAppointments(animated: animated,
                          onDismissed: onDismissed)
  }
  
  /**
   add `child` `Coordinator`to `children` list of `Coordinator`s and present `child` `Coordinator`
   */
  public func presentChild(_ child: Coordinator,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) {
    self.children.append(child)
    child.present(animated: animated) { [weak self, weak child] in
      guard let self = self,
            let child = child
      else { return }
      self.removeChild(child)
      onDismissed?()
    }
  }
  
  private func removeChild(_ child: Coordinator) {
    /// `children` includes `child`!!
    guard let index = self.children
      .firstIndex(where: { $0 === child })
    else { return }
    self.children.remove(at: index)
  }
}

