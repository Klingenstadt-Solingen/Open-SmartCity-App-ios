//
//  AppDI+OSCAJobsUIDI.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 27.07.22.
//  reviewed by Stephan Breidenbach on 27.08.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCAJobs
import OSCAJobsUI
import OSCASafariView
import OSCANetworkService
import UIKit

extension AppDI {
  final class OSCAJobsUIDI {
    /**
     `OSCAJobsUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let webViewModule: OSCASafariView
      let networkService: OSCANetworkService
      let userDefaults: UserDefaults
      let deeplinkScheme: String
    } // end struct Dependencies
    
    private let dependencies: Dependencies
    
    var jobsFlow: Coordinator?
    var dataModule: OSCAJobs?
    
    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    // MARK: - Feature Module dependencies
    
    func makeOSCAJobsDependencies() -> OSCAJobsDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAJobsDependencies = OSCAJobsDependencies(networkService: dependencies.networkService,
                                                                              userDefaults: dependencies.userDefaults)
      return dataModuleDependencies
    } // end func makeOSCAJobsDependencies
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAJobsModule() -> OSCAJobs {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let jobsModule = dataModule {
        return jobsModule
      } else {
        let jobsModule = OSCAJobs.create(with: makeOSCAJobsDependencies())
        dataModule = jobsModule
        return jobsModule
      }// end if
    } // end func makeOSCAJobs
    
    // MARK: - Feature UI Module shadow settings
    
    func makeOSCAJobsUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.2,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    
    func makeOSCAJobsUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    } // end func make OSCAColorSettings for press releases ui
    
    // MARK: - Feature UI Module Type face settings
    
    func makeOSCAJobsUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    } // end func make OSCAFontSettings for press releases ui
    
    // MARK: - Feature UI Module Config
    
    func makeOSCAJobsUIConfig() -> OSCAJobsUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let placeholderImage = UIImage(named: "placeholder_image",
                                     in: OSCASolingen.bundle,
                                     with: .none)
      return OSCAJobsUIConfig(title: "OSCAJobsUI",
                              shadowSettings: makeOSCAJobsUIShadowSettings(),
                              cornerRadius: 10.0,
                              placeholderImage: placeholderImage,
                              fontConfig: makeOSCAJobsUIFontSettings(),
                              colorConfig: makeOSCAJobsUIColorSettings())
    } // end func make OSCAJobsUIConfig
    
    // MARK: - Feature UI Module dependencies
    
    func makeOSCAJobsUIModuleDependencies() -> OSCAJobsUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAJobsUIDependencies(dataModule: makeOSCAJobsModule(),
                                    moduleConfig: makeOSCAJobsUIConfig(),
                                    webViewModule: self.dependencies.webViewModule)
    } // end func make OSCAJobsUI dependencies
    
    // MARK: - Feature UI Module
    
    func makeOSCAJobsUIModule() -> OSCAJobsUI {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      return OSCAJobsUI.create(with: makeOSCAJobsUIModuleDependencies())
    } // end func makePressReleaseModule
  } // end final class OSCAJobsUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAJobsUIDI {
  /// singleton `Coordinator`
  func makeOSCAJobsFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let jobsFlow = jobsFlow {
      return jobsFlow
    } else {
      let flow = makeOSCAJobsUIModule()
        .getJobsFlowCoordinator(router: router)
      jobsFlow = flow
      return flow
    }// end if
  } // end func make module flow coordinator
}// end extension final class OSCAJobsUIDI
