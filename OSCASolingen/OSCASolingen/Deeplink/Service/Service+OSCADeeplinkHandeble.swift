//
//  Service+OSCADeeplinkHandeble.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.09.22.
//  Reviewed by Stephan Breidenbach on 19.09.2022.
//

import Foundation
import OSCAEssentials
import OSCAJobsUI
import OSCAPublicTransportUI
import OSCAEventsUI
import OSCACoworkingUI
import UIKit

extension ServiceFlow: OSCADeeplinkHandeble {
  var prefixes: [String] {
    return dependencies
      .makeDeeplinkPrefixes()
  }// end var prefixes
  
  ///```console
  ///xcrun simctl openurl booted \
  /// "solingen://.../"
  /// ```
  public func canOpenURL(_ url: URL) -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return prefixes.contains(where: { url.absoluteString.hasPrefix($0) })
  }// end public func canOpenURL
  
  public func openURL(_ url: URL,
                      onDismissed:(() -> Void)?) throws -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard canOpenURL(url)
    else { return }
    showServiceMain(with: url,
                    animated: true,
                    onDismissed: onDismissed)
  }// end public func openURL
  
  public func showServiceMain(with url: URL,
                              animated: Bool,
                              onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let serviceVC = serviceVC {
      serviceVC.didReceiveDeeplink(with: url)
    } else {
      showServiceMain(animated: animated,
                      onDismissed: onDismissed)
      guard let serviceVC = serviceVC
      else { return }
      serviceVC.didReceiveDeeplink(with: url)
    }// end if
  }// end public func showServiceMain with url
  
  func navigateTo(serviceMenu: ServiceMenu,
                  with url: URL) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let childFlow = childFlow {
      removeChild(childFlow)
      self.childFlow = nil
    }// end if
    guard let seque = serviceMenu.seque else { return }
    var typedFlow: OSCADeeplinkHandeble?
    switch seque {
    case .publicTransport:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCAPublicTransportDeeplinkHandeble(router: router)
    case .coworking:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCACoworkingDeeplinkHandeble(router: router)
    case .jobs:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCAJobsDeeplinkHandeble(router: router)
    case .events:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
        if let url = URL(string: "\(dependencies.deeplinkScheme)://events/") {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    case .http:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
    case .art:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getBeaconSearchHandeble(router: router)
    case .mobilityMonitor:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCAMobilityHandeble(router: router)
    case .investment:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      #warning("TODO: implementation")
    }// end switch case
    
    guard let typedFlow = typedFlow,
          let flow = typedFlow as? Coordinator,
          typedFlow.canOpenURL(url)
    else { return }
    presentChild(flow,
                 with:url,
                 animated: false) { [weak self] in
      guard let `self` = self
      else { return }
      self.childFlow = nil
    }// end onDismissed closure
    self.childFlow = flow
  }// end func navigateTo
  
  public func presentChild(_ child: Coordinator,
                           with url: URL,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let typedChild = child as? OSCADeeplinkHandeble
    else { return }
    children.append(child)
    do {
      try typedChild.openURL(url) { [weak self, weak child] in
        guard let self = self,
              let child = child
        else { return }
        self.removeChild(child)
        onDismissed?()
      } // end on dismissed closure
    } catch {
      return
    }// end do catch
  } // end public func presentChild
}// end extension final class ServiceFlow
