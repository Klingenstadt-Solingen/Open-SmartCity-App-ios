//
//  TownhallFlow.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 21.06.22.
//  Reviewed by Stephan Breidenbach on 02.09.2022.
//

import Foundation
import OSCAContactUI
import OSCACoworkingUI
import OSCADefectUI
import OSCAEssentials
import OSCAWasteUI
import OSCASafariView

protocol TownhallFlowDependencies {
  var deeplinkScheme: String { get }
  func getOSCAContactDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCADefectDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCAWasteDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func getOSCAAppointmentsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble
  func makeDeeplinkPrefixes() -> [String]
  func makeTownhallViewController(actions: TownhallViewModelActions) -> TownhallViewController
  func makeOSCAContactFormFlowCoordinator(router: Router) -> Coordinator
  func makeOSCAWasteFlowCoordinator(router: Router) -> Coordinator
  func makeOSCADefectFormFlowCoordinator(router: Router) -> Coordinator
  func makeOSCASafariViewFlowCoordinator(router: Router, url: URL) -> Coordinator
  func makeOSCAAppointmentsFlowCoordinator(router: Router) -> Coordinator
}// end protocol TownhallFlowDependencies

/**
 The concrete coordinator implements the coordinator protocol. It knows how to create concrete view controllers and the order in which view controllers should be displayed.
 */
final class TownhallFlow: Coordinator {
  /// list of `Coordinator`s
  var children: [Coordinator] = []
  
  /// router injected via initializer: `router`will be used to push and pop view controllers
  var router: Router
  
  let dependencies: TownhallFlowDependencies
  
  /// townhall view controller instance
  weak var townhallVC: TownhallViewController?
  /// child flow coordinator instance
  var childFlow: Coordinator?
  
  var safariFlow: OSCASafariViewFlowCoordinator?
  
  init(router: Router,
       dependencies: TownhallFlowDependencies) {
    self.router = router
    self.dependencies = dependencies
  } // end init
  
  func navigateTo(townhallMenu: TownhallMenu /* , imageData: Data? */ ) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let childFlow = childFlow {
      removeChild(childFlow)
      self.childFlow = nil
    }// end if
    var flow: Coordinator?
    guard let seque = townhallMenu.seque else { return }
    
    switch seque {
    case .contact:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies.makeOSCAContactFormFlowCoordinator(router: router)
    case .waste:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies.makeOSCAWasteFlowCoordinator(router: router)
    case .defect:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = dependencies.makeOSCADefectFormFlowCoordinator(router: router)
    case .school:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      #warning("TODO: investments")
    case .http:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      guard let urlString = townhallMenu.link,
            let url = URL(string: urlString)
      else { return }
      
      if let safariFlow = self.safariFlow {
        safariFlow.url = url
        flow = safariFlow
      } else {
        flow = self.dependencies.makeOSCASafariViewFlowCoordinator(router: router, url: url)
        self.safariFlow = flow as? OSCASafariViewFlowCoordinator
      }
    case .appointment:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      flow = self.dependencies.makeOSCAAppointmentsFlowCoordinator(router: router)
    }
    
    guard let flow = flow else { return }
    
    presentChild(flow, animated: false)
    
    self.childFlow = flow
  }// end func navigateTo
  
  func showTownhallMain(animated: Bool,
                        onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let townhallVC = townhallVC {
      router.present(townhallVC,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      let townhallViewControllerActions = TownhallViewModelActions(navigateTo: navigateTo(townhallMenu:),
                                                                   navigateToWithURL: navigateTo(townhallMenu:with:))
      
      /// instantiate view controller with view model actions
      let townhallViewController: TownhallViewController = dependencies.makeTownhallViewController(actions: townhallViewControllerActions)
      /// present view controller
      router.present(townhallViewController,
                     animated: animated,
                     onDismissed: onDismissed)
      /// local handle to the presenting `CityViewController` instance
      townhallVC = townhallViewController
    }// end if
  }// end func showTownhallMain
  /// present townhall view controller method
  /// * instantiate view model actions
  /// * instantiate view controller with view model actions
  /// * present view controller
  ///
  func present(animated: Bool,
               onDismissed: (() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    showTownhallMain(animated: animated,
                     onDismissed: onDismissed)
  } // end func present
} // end final class TownhallFlow

extension TownhallFlow {
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
} // end extension public final class TownhallFlow
