//
//  CityFlow+OSCADeeplinkHandeble.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.09.22.
//

import Foundation
import OSCAEssentials
import OSCAWeatherUI
import OSCAMapUI

extension CityFlow: OSCADeeplinkHandeble {
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
    
    showCityMain(with: url,
                 animated: true,
                 onDismissed: onDismissed)
  }// end public func openURL
  
  public func showCityMain(with url: URL,
                           animated: Bool,
                           onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let cityVC = cityVC {
      cityVC.didReceiveDeeplink(with: url)
    } else {
      showCityMain(animated: animated,
                   onDismissed: onDismissed)
      guard let cityVC = cityVC
      else { return }
      cityVC.didReceiveDeeplink(with: url)
    }// end if
  }// end public func showCityMain with url
  
  public func showWeatherSceneWithURL(url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      if let weatherScene = weatherScene {
        guard let weatherFlow = weatherScene as? OSCAWeatherFlowCoordinator,
              weatherFlow.canOpenURL(url)
        else { return }
        try weatherFlow.openURL(url,
                                onDismissed: nil)
      } else {
        showWeatherScene(selectedWeatherStationId: "")
        guard let weatherScene = weatherScene
        else { return }
        guard let weatherFlow = weatherScene as? OSCAWeatherFlowCoordinator,
              weatherFlow.canOpenURL(url)
        else { return }
        try weatherFlow.openURL(url,
                                onDismissed: nil)
      }// end if
    }catch {
      return
    }// end do catch
    return
  }// end public func showWeatherSceneWithURL
  
  public func showMapSceneWithURL(url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      if let mapScene = mapScene {
        guard let mapFlow = mapScene as? OSCAMapFlowCoordinator,
              mapFlow.canOpenURL(url)
        else { return }
        try mapFlow.openURL(url,
                            onDismissed: nil)
      } else {
        showMapScene()
        guard let mapScene = mapScene
        else { return }
        guard let mapFlow = mapScene as? OSCAMapFlowCoordinator,
              mapFlow.canOpenURL(url)
        else { return }
        try mapFlow.openURL(url,
                            onDismissed: nil)
      }// end if
    }catch {
      return
    }// end do catch
    return
  }// end public func showMapSceneWithURL
}// end extension final class CityFlow
