//
//  HomeTabRootFlow+OSCADeeplinkHandeble.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.09.22.
//

import Foundation
import OSCAEssentials
/* Disabled module Corona
import OSCACoronaUI
 */
import OSCAPressReleasesUI

extension HomeTabRootCoordinator: OSCADeeplinkHandeble {
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
    
    showHomeTabRoot(with: url,
                    onDismissed: onDismissed)
  }// end public func openURL
  
  public func showHomeTabRoot(with url: URL,
                              onDismissed:(() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// is there a home tab root controller?
    if let homeTabRootVC = homeTabRootViewController {
      homeTabRootVC.didReceiveDeeplink(with: url)
    } else {
      showHomeTabRoot(animated: true,
                      onDismissed: onDismissed)
      guard let homeTabRootVC = homeTabRootViewController
      else { return }
      homeTabRootVC.didReceiveDeeplink(with: url)
    }// end if
  }// end public func showHomeTabRoot with url
  
  func handle(flow: Coordinator,
              id: String,
              with url: URL,
              onDismissed: (() -> Void)?) -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      switch id {
      case "tabbaritem_home_title": do {
        guard let typedFlow = flow as? CityFlow,
              typedFlow.canOpenURL(url)
        else { return false }
        try typedFlow.openURL(url,
                              onDismissed: onDismissed)
      }// end case
        /* Disabled module Corona
      case "tabbaritem_corona_title": do {
        guard let typedFlow = flow as? OSCACoronaFlowCoordinator,
              typedFlow.canOpenURL(url)
        else { return false }
        try typedFlow.openURL(url,
                              onDismissed: onDismissed)
      }// end case
         */
      case "tabbaritem_settings_title": do {
        guard let typedFlow = flow as? SettingsFlow,
              typedFlow.canOpenURL(url)
        else { return false }
        try typedFlow.openURL(url,
                              onDismissed: onDismissed)
      }// end case
      case "tabbaritem_townhall_title": do {
        guard let typedFlow = flow as? TownhallFlow,
              typedFlow.canOpenURL(url)
        else { return false }
        try typedFlow.openURL(url,
                              onDismissed: onDismissed)
      }// end case
      case "tabbaritem_press_title": do {
        guard let typedFlow = flow as? OSCAPressReleasesFlowCoordinator,
              typedFlow.canOpenURL(url)
        else { return false }
        try typedFlow.openURL(url,
                              onDismissed: onDismissed)
      }// end case
      case "tabbaritem_service_title": do {
        guard let typedFlow = flow as? ServiceFlow,
              typedFlow.canOpenURL(url)
        else { return false }
        try typedFlow.openURL(url,
                              onDismissed: onDismissed)
      }// end case
      default: return false
      } // end switch case
    } catch {
      return false
    }// end do catch
    return true
  }// end func handle flow id with url
  
  func handle(homeTabItem: HomeTabItemViewModel, with url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let _ = self.homeTabRootViewController,
          let rootBarItem: RootBarItem = getRootBarItem(from: homeTabItem),
          let rootNavigationRouter = rootNavigationRouters[rootBarItem],
          let flow = getChildCoordinator(from: rootNavigationRouter)
    else { return }
    rootNavigationRouter.navigateToRoot(animated: true)
    let _ = handle(flow: flow,
                   id: rootBarItem.id,
                   with: url,
                   onDismissed: self.onDismissed)
  } // end private func showNthTab
}// end extension final class CityFlow

