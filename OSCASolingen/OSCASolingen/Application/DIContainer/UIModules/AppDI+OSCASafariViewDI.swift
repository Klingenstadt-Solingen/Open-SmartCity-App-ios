//
//  AppDI+OSCASafariViewDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 27.08.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCASafariView
import UIKit

extension AppDI {
  final class OSCASafariViewDI {
    
    var webFlow: Coordinator?
    var webUrl: URL? = nil
    
    
    // MARK: - Feature UI Module Color settings
    func makeOSCASafariViewColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCASafariViewFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }
    
    // MARK: - Feature UI Module Config
    func makeOSCASafariViewConfig() -> OSCASafariView.Config {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCASafariView.Config(title: "OSCASafariView",
                                   fontConfig: makeOSCASafariViewFontSettings(),
                                   colorConfig: makeOSCASafariViewColorSettings())
    }
    
    // MARK: - Feature UI Module dependencies
    func makeOSCASafariViewModuleDependencies() -> OSCASafariView.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCASafariView.Dependencies(moduleConfig: makeOSCASafariViewConfig())
    }
    
    // MARK: - Feature UI Module
    func makeOSCASafariViewModule() -> OSCASafariView {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCASafariView.create(with: makeOSCASafariViewModuleDependencies())
    }
  }
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCASafariViewDI {
  /// singleton `Coordinator`
  func makeOSCASafariViewFlowCoordinator(url: URL, router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let webFlow = webFlow, webUrl == url {
      return webFlow
    } else {
      webUrl = url
      let flow = makeOSCASafariViewModule()
        .getSafariViewFlowCoordinator(router: router, url: url)
      webFlow = flow
      return flow
    }// end if
  }// end func makeOSCASafariViewFlowCoordinator
}// end extension final class OSCASafariViewDI
