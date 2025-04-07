//
//  OSCAAppointments+DIContainer.swift
//  OSCAAppointments
//
//  Created by Ömer Kurutay on 19.02.23.
//

import Foundation

extension OSCAAppointments {
  final class DIContainer {
    private let dependencies: OSCAAppointments.Dependencies
    
    public init(dependencies: OSCAAppointments.Dependencies) {
      self.dependencies = dependencies
    }
  }
}
