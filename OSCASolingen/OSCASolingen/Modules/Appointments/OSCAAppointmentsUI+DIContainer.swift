//
//  OSCAAppointmentsUI+DIContainer.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 20.02.23.
//

import OSCAEssentials
import OSCASafariView
import Foundation

extension OSCAAppointmentsUI {
  final class DIContainer {
    
    let dependencies: OSCAAppointmentsUI.Dependencies

    public init(dependencies: OSCAAppointmentsUI.Dependencies) {
      #if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
      #endif
      self.dependencies = dependencies
    }
  }
}

// MARK: - OSCAAppointmentsUI.DIContainer + OSCAAppointmentsFlowCoordinatorDependencies
extension OSCAAppointmentsUI.DIContainer: OSCAAppointmentsFlowCoordinatorDependencies {
  // MARK: Appointments
  func makeOSCAAppointmentsViewModel(actions: OSCAAppointmentsViewModel.Actions) -> OSCAAppointmentsViewModel {
    return OSCAAppointmentsViewModel(dependencies: self.dependencies,
                                     actions: actions)
  }
  
  func makeOSCAAppointmentsViewController(actions: OSCAAppointmentsViewModel.Actions) -> OSCAAppointmentsViewController {
    return OSCAAppointmentsViewController
      .create(with: self.makeOSCAAppointmentsViewModel(
        actions: actions))
  }
}

// MARK: - Flow coordinators
extension OSCAAppointmentsUI.DIContainer {
  func makeOSCAAppointmentsFlowCoordinator(router: Router) -> OSCAAppointmentsFlowCoordinator {
    OSCAAppointmentsFlowCoordinator(router: router,
                                    dependencies: self)
  }
  
  // MARK: SafariView
  func makeSafariViewFlowCoordinator(router: Router, url: URL) -> OSCASafariViewFlowCoordinator {
    return dependencies.webViewModule.getSafariViewFlowCoordinator(
      router: router,
      url: url)
  }
}
