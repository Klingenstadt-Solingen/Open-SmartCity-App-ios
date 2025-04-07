//
//  OSCAAppointmentsViewModel.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 22.11.22.
//

import OSCAEssentials
// After seperating from core app import OSCAAppointments
import Foundation
import Combine

public final class OSCAAppointmentsViewModel {
  
  let dependencies: OSCAAppointmentsUI.Dependencies
  let config: OSCAAppointmentsUI.Config
  private let actions: OSCAAppointmentsViewModel.Actions
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  init(dependencies: OSCAAppointmentsUI.Dependencies,
       actions     : OSCAAppointmentsViewModel.Actions) {
    self.dependencies = dependencies
    self.config       = dependencies.moduleConfig
    self.actions      = actions
  }
  
  // MARK: - OUTPUT
  
  @Published private(set) var state: OSCAAppointmentsViewModel.State = .loading
  @Published private(set) var appointments: [OSCAAppointment] = []
  
  // MARK: Localized Strings
  
  let screenTitle: String = NSLocalizedString(
    "appointments_screen_title",
    bundle: OSCAAppointmentsUI.bundle,
    comment: "The screen title")
  let alertTitleError: String = NSLocalizedString(
    "error_alert_title_error",
    bundle: OSCAAppointmentsUI.bundle,
    comment: "The alert title for an error")
  let alertActionConfirm: String = NSLocalizedString(
    "error_alert_title_confirm",
    bundle: OSCAAppointmentsUI.bundle,
    comment: "The alert action title to confirm")
  
  // MARK: Private
  
}

// MARK: - Data access
extension OSCAAppointmentsViewModel {
  private func fetchAppointments() {
    self.state = .loading
    self.dependencies.dataModule.fetchAllAppointments()
      .map {
        $0.filter({ $0.visible == true })
      }
      .map {
        $0.sorted(by: { $0.position ?? 99 < $1.position ?? 99 })
      }
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.appointmentsFetching)
        }
      } receiveValue: { fetchedAppointments in
        self.appointments = fetchedAppointments
      }
      .store(in: &self.bindings)

  }
}

// MARK: - View Model Input
extension OSCAAppointmentsViewModel {
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.fetchAppointments()
  }
  
  func didSelectItem(at index: Int) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let surveyUrl = self.appointments[index].url,
          let url = URL(string: surveyUrl)
    else { return }
    self.actions.showSafariView(url)
  }
}

// MARK: - Actions
public extension OSCAAppointmentsViewModel {
  struct Actions {
    let showSafariView: (URL) -> Void
  }
}

// MARK: - Section
extension OSCAAppointmentsViewModel {
  enum Section {
    case appointment
  }
}

// MARK: - Error
public extension OSCAAppointmentsViewModel {
  enum Error {
    case appointmentsFetching
  }
}

// MARK: - State
public extension OSCAAppointmentsViewModel {
  enum State: Equatable {
    case loading
    case finishedLoading
    case error(OSCAAppointmentsViewModel.Error)
  }
}
