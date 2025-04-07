//
//  OSCAAppointmentsUI.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 20.02.23.
//

import OSCAEssentials
// After seperating from core app import OSCAAppointments
import OSCASafariView
import UIKit

public struct OSCAAppointmentsUI: OSCAModule {
  // MARK: Lifecycle
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  init(with config: OSCAUIModuleConfig) {
#if SWIFT_PACKAGE
    Self.bundle = .module
#else
    guard let bundle = Bundle(identifier: bundlePrefix)
    else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCAAppointmentsUI.Config
    else { fatalError("Config couldn't be initialized!") }
    OSCAAppointmentsUI.configuration = extendedConfig
  }
  
  ///  module configuration
  public internal(set) static var configuration: OSCAAppointmentsUI.Config!
  /// module `Bundle`
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!

  /// version of the module
  public var version: String = "1.0.2"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.solingen.core" // After seperating from core app "de.osca.appointments.ui"
  
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCAAppointmentsUI.Dependencies) -> OSCAAppointmentsUI {
    var module = Self(with: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCAAppointmentsUI.DIContainer(
      dependencies: moduleDependencies)
    return module
  }

  public func getOSCAAppointmentsFlowCoordinator(router: Router) -> OSCAAppointmentsFlowCoordinator {
    let flow = moduleDIContainer.makeOSCAAppointmentsFlowCoordinator(router: router)
    return flow
  }

  // MARK: Private

  /// module DI container
  private var moduleDIContainer: OSCAAppointmentsUI.DIContainer!
}

// MARK: - Dependencies
extension OSCAAppointmentsUI {
  public struct Dependencies {
    public init(moduleConfig: OSCAAppointmentsUI.Config,
                dataModule: OSCAAppointments,
                webViewModule: OSCASafariView,
                analyticsModule: OSCAAnalyticsModule? = nil) {
      self.moduleConfig = moduleConfig
      self.dataModule = dataModule
      self.webViewModule = webViewModule
      self.analyticsModule = analyticsModule
    }
    public let moduleConfig: OSCAAppointmentsUI.Config
    public let dataModule: OSCAAppointments
    public let webViewModule: OSCASafariView
    public let analyticsModule: OSCAAnalyticsModule?
  }
}

// MARK: - Config
public protocol OSCAAppointmentsUIConfig: OSCAUIModuleConfig {
  /// shadow configuration
  var shadow: OSCAShadowSettings { get set }
  /// `UIView` corner radius
  var cornerRadius: Double { get set }
  /// `UIView` border width
  var borderWidth: Double { get set }
  /// placeholder image configuration
  var placeholderImage: (image: UIImage, color: UIColor?)? { get set }
  ///  app deeplink scheme
  var deeplinkScheme: String { get set }
}

public extension OSCAAppointmentsUI {
  /// The configuration of the `OSCAAppointmentsUI` module
  struct Config: OSCAAppointmentsUIConfig {
    // MARK: Lifecycle
    
    public init(title: String?,
                fontConfig: OSCAFontSettings,
                colorConfig: OSCAColorSettings,
                shadow: OSCAShadowSettings = OSCAShadowSettings(
                  opacity: 0.2,
                  radius: 10,
                  offset: CGSize(width: 0, height: 2)),
                cornerRadius: Double = 16.0,
                borderWidth: Double = 1.0,
                placeholderImage: (image: UIImage, color: UIColor?)? = nil,
                deeplinkScheme: String = "solingen") {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      self.title = title
      self.fontConfig = fontConfig
      self.colorConfig = colorConfig
      self.shadow = shadow
      self.cornerRadius = cornerRadius
      self.borderWidth = borderWidth
      self.placeholderImage = placeholderImage
      self.deeplinkScheme = deeplinkScheme
    }
    
    /// module title
    public var title: String?
    /// typeface configuration
    public var fontConfig: OSCAFontConfig
    /// color configuration
    public var colorConfig: OSCAColorConfig
    /// shadow configuration
    public var shadow: OSCAShadowSettings
    /// `UIView` corner radius
    public var cornerRadius: Double
    /// `UIView` border width
    public var borderWidth: Double
    /// placeholder image configuration
    public var placeholderImage: (image: UIImage, color: UIColor?)?
    /// app deeplink scheme URL part before `://`
    public var deeplinkScheme: String
  }
}
