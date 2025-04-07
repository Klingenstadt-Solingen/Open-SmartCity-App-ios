//
//  OSCAAppointmentsFlow+OSCADeeplinkHandeble.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 20.02.23.
//

import OSCAEssentials
import Foundation

extension OSCAAppointmentsFlowCoordinator: OSCADeeplinkHandeble {
  public func canOpenURL(_ url: URL) -> Bool {
    let deeplinkScheme: String = self.dependencies
      .deeplinkScheme
    return url.absoluteString.hasPrefix("\(deeplinkScheme)://appointments")
  }
  
  public func openURL(_ url: URL, onDismissed: (() -> Void)?) throws {
    guard canOpenURL(url) else { return }
    self.showAppointments(animated: true,
                          onDismissed: onDismissed)
  }
}
