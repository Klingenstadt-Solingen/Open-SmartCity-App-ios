//
//  OSCAAppointmentsDI+DeeplinkHandler.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 20.02.23.
//

import Foundation

extension OSCAAppointmentsUI.DIContainer {
  var deeplinkScheme: String {
    self.dependencies.moduleConfig.deeplinkScheme
  }
}
