//
//  AppDI+OSCAAppointmentsUIDI.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 20.02.23.
//

import OSCAEssentials
import OSCANetworkService
// After seperating from core app import OSCAAppointments
// After seperating from core app import OSCAAppointmentsUI
import OSCASafariView
import UIKit

extension AppDI {
  final class OSCAAppointmentsUIDI {
    /**
     `OSCAAppointmentsUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService: OSCANetworkService
      let userDefaults: UserDefaults
      let webViewModule: OSCASafariView
      let deeplinkScheme: String
    }
    
    private let dependencies: Dependencies
    
    var appointmentsFlow: Coordinator?
    var dataModule: OSCAAppointments?
    
    init(dependencies: OSCAAppointmentsUIDI.Dependencies) {
      self.dependencies = dependencies
    }
    
    // MARK: - Feature UI Module Placeholder Image
    func makeOSCAAppointmentsUIPlaceholderImage() -> (image: UIImage, color: UIColor?)? {
      guard let image = UIImage(named: "placeholder_image",
                                in: OSCASolingen.bundle,
                                with: .none)
      else { return nil }
      let color: UIColor = .clear
      return (image, color)
    }
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCAAppointmentsUIShadowSettings() -> OSCAShadowSettings {
      return OSCAShadowSettings(opacity: 0.2,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAAppointmentsUIColorSettings() -> OSCAColorSettings {
      return OSCAColorSettings()
    }
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCAAppointmentsUIFontSettings() -> OSCAFontSettings {
      return OSCAFontSettings()
    }
    
    // MARK: - Feature UI Module Config
    func makeOSCAAppointmentsUIConfig() -> OSCAAppointmentsUI.Config {
      return OSCAAppointmentsUI.Config(
        title           : "OSCAAppointmentsUI",
        fontConfig      : self.makeOSCAAppointmentsUIFontSettings(),
        colorConfig     : self.makeOSCAAppointmentsUIColorSettings(),
        shadow          : self.makeOSCAAppointmentsUIShadowSettings(),
        cornerRadius    : 10,
        borderWidth     : 1.0,
        placeholderImage: self.makeOSCAAppointmentsUIPlaceholderImage(),
        deeplinkScheme  : self.dependencies.deeplinkScheme)
    }
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAAppointmentsUIModuleDependencies() -> OSCAAppointmentsUI.Dependencies {
      let dataModuleDependencies = OSCAAppointments.Dependencies(
        networkService: self.dependencies.networkService,
        userDefaults: self.dependencies.userDefaults)
      let dataModule = OSCAAppointments.create(
        with: dataModuleDependencies)
      return OSCAAppointmentsUI.Dependencies(
        moduleConfig: self.makeOSCAAppointmentsUIConfig(),
        dataModule: dataModule,
        webViewModule: self.dependencies.webViewModule)
    }
    
    // MARK: - Feature Module dependencies
    func makeOSCAAppointmentsModuleDependencies() -> OSCAAppointments.Dependencies {
      return OSCAAppointments.Dependencies(
        networkService: self.dependencies.networkService,
        userDefaults: self.dependencies.userDefaults)
    }
    
    // MARK: - Feature UI Module
    func makeOSCAAppointmentsUIModule() -> OSCAAppointmentsUI {
      return OSCAAppointmentsUI.create(
        with: self.makeOSCAAppointmentsUIModuleDependencies())
    }
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAAppointmentsModule() -> OSCAAppointments {
      if let appointmentsModule = self.dataModule {
        return appointmentsModule
      } else {
        let appointmentsModule = OSCAAppointments.create(
          with: self.makeOSCAAppointmentsModuleDependencies())
        self.dataModule = appointmentsModule
        return appointmentsModule
      }
    }
  }
}

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAAppointmentsUIDI {
  /// singleton `Coordinator`
  func makeOSCAAppointmentsFlowCoordinator(router: Router) -> Coordinator {
    if let appointmentsFlow = self.appointmentsFlow {
      return appointmentsFlow
    } else {
      let flow = self.makeOSCAAppointmentsUIModule()
        .getOSCAAppointmentsFlowCoordinator(router: router)
      return flow
    }
  }
}
