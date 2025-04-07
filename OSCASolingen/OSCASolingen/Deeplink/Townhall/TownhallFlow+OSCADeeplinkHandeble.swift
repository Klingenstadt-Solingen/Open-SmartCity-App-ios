//
//  TownhallFlow+OSCADeeplinkHandeble.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.09.22.
//

import Foundation
import OSCAEssentials
import OSCAContactUI
import OSCADefectUI
import OSCAWasteUI

extension TownhallFlow: OSCADeeplinkHandeble {
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
    showTownhallMain(with: url,
                     animated: true,
                     onDismissed: onDismissed)
  }// end public func openURL
  
  public func showTownhallMain(with url: URL,
                               animated: Bool,
                               onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let townhallVC = townhallVC {
      townhallVC.didReceiveDeeplink(with: url)
    } else {
      showTownhallMain(animated: animated,
                       onDismissed: onDismissed)
      guard let townhallVC = townhallVC
      else { return }
      townhallVC.didReceiveDeeplink(with: url)
    }// end if
  }// end public func showTownhallMain with url
  
  func navigateTo(townhallMenu: TownhallMenu,
                  with url: URL) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let childFlow = childFlow {
      removeChild(childFlow)
      self.childFlow = nil
    }// end if
    guard let seque = townhallMenu.seque else { return }
    var typedFlow: OSCADeeplinkHandeble?
    switch seque {
    case .contact:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCAContactDeeplinkHandeble(router: router)
    case .waste:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCAWasteDeeplinkHandeble(router: router)
    case .defect:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = dependencies
        .getOSCADefectDeeplinkHandeble(router: router)
    case .school:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
    case .http:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
    case .appointment:
#if DEBUG
      print("\(String(describing: self)): \(#function): \(seque.rawValue)")
#endif
      typedFlow = self.dependencies
        .getOSCAAppointmentsDeeplinkHandeble(router: router)
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
}// end extension final class TownhallFlow
