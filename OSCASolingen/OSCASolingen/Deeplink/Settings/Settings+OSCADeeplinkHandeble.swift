//
//  Settings+OSCADeeplinkHandeble.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.09.22.
//

import Foundation
import OSCAEssentials

extension SettingsFlow: OSCADeeplinkHandeble {
  var prefixes: [String] {
    return dependencies
      .makeDeeplinkPrefixes()
  }// end var prefixes
  
  /// ```console
  ///  xcrun simctl openurl booted \
  ///    "solingen://.../"
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
    showSettingsMain(animated: true,
                    onDismissed: onDismissed)
  }// end public func openURL
}// end extension final class SettingsFlow
