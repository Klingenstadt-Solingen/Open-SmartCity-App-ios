//
//  ServiceFlow.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 24.06.22.
//  reviewed by Stephan Breidenbach on 02.09.2022.
//

import Foundation
import OSCAEssentials
import UIKit

protocol ServiceFlowDependencies {
  var deeplinkScheme: String { get }
  func makeDeeplinkPrefixes() -> [String]
  func getOSCAPublicTransportDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCAEventsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCACoworkingDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCAJobsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCAMobilityHandeble(router: Router) -> OSCADeeplinkHandeble
  func getBeaconSearchHandeble(router: Router) -> OSCADeeplinkHandeble
  func makeServiceListViewController(actions: ServiceListViewModelActions) -> ServiceListViewController
  // route to OSCAPublicTransport/UI
  func makeOSCAPublicTransportCoordinator(router: Router) -> Coordinator
  // route to OSCAEvents/UI
  func makeOSCAEventsCoordinator(router: Router) -> Coordinator
  // route to OSCACoworking/UI
  func makeOSCACoworkingCoordinator(router: Router) -> Coordinator
  func makeOSCAJobsCoordinator(router: Router) -> Coordinator
  func makeOSCASafariViewCoordinator(router: Router, url: URL) -> Coordinator
  func makeBeaconSearchFlow(router: Router) -> Coordinator
  func makeOSCAMobilityFlow(router: Router) -> Coordinator
} // end protocol ServiceFlowDependencies

/**
 The concrete coordinator implements the coordinator protocol. It knows how to create concrete view controllers and the order in which view controllers should be displayed.
 */
final class ServiceFlow: Coordinator {
  /// list of `Coordinator`s
  var children: [Coordinator] = []
  
  /// router injected via initializer: `router`will be used to push and pop view controllers
  var router: Router
  
  let dependencies: ServiceFlowDependencies
  
  /// Module Navigation view controller instance
  weak var serviceVC: ServiceListViewController?
  var childFlow: Coordinator?
  
  init(router: Router,
       dependencies: ServiceFlowDependencies) {
    self.router = router
    self.dependencies = dependencies
  } // end init
  
  private func navigateTo(serviceMenu: ServiceMenu /* , imageData: Data? */ ) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let childFlow = childFlow {
      removeChild(childFlow)
      self.childFlow = nil
    } // end if
    var flow: Coordinator?
    guard let seque = serviceMenu.seque else { return }
      var urlToOpen: URL? = nil
    switch seque {
    case ServiceMenu.Seque.events:
        if let url = URL(string: "\(dependencies.deeplinkScheme)://events/") {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    case ServiceMenu.Seque.publicTransport:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies
        .makeOSCAPublicTransportCoordinator(router: router)
    case ServiceMenu.Seque.coworking:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies
        .makeOSCACoworkingCoordinator(router: router)
    case ServiceMenu.Seque.jobs:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies
        .makeOSCAJobsCoordinator(router: router)
    case ServiceMenu.Seque.http:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      guard let urlString = serviceMenu.link,
            let url = URL(string: urlString) else { return }
      flow = dependencies
        .makeOSCASafariViewCoordinator(router: router, url: url)
    case ServiceMenu.Seque.art:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies
        .makeBeaconSearchFlow(router: router)
    case ServiceMenu.Seque.mobilityMonitor:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies.makeOSCAMobilityFlow(router: router)
      
    case ServiceMenu.Seque.investment:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
    } // end switch case
    
    guard let flow = flow else { return }
    
    presentChild(flow, animated: false)
  } // end private func navigateTo service menu
  
  func showServiceMain(animated: Bool,
                       onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let serviceVC = serviceVC {
      router.present(serviceVC,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      let serviceListViewControllerActions = ServiceListViewModelActions(navigateTo: navigateTo(serviceMenu:),
                                                                         navigateToWithURL: navigateTo(serviceMenu:with:))
      
      /// instantiate view controller with view model actions
      let serviceListViewController: ServiceListViewController = dependencies.makeServiceListViewController(actions: serviceListViewControllerActions)
      /// present view controller
      router.present(serviceListViewController,
                     animated: animated,
                     onDismissed: onDismissed)
      /// local handle to the presenting `ServiceListViewController` instance
      serviceVC = serviceListViewController
    } // end if
  } // end func showServiceMain
  
  /// present Module Navigation view controller method
  /// * instantiate view model actions
  /// * instantiate view controller with view model actions
  /// * present view controller
  ///
  func present(animated: Bool,
               onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    showServiceMain(animated: animated,
                    onDismissed: onDismissed)
  } // end func present
} // end final class ServiceFlow

extension ServiceFlow {
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
  
  func removeChild(_ child: Coordinator) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// `children` includes `child`!!
    guard let index = children.firstIndex(where: { $0 === child }) else { return } // end guard
    children.remove(at: index)
  } // end private func removeChild
} // end extension public final class ServiceFlow
