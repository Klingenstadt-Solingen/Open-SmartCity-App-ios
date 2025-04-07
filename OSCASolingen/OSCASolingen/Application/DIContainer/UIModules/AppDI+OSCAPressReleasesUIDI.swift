//
//  AppDI+OSCAPressReleasesUIDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 27.01.22.
//  Reviewed by Stephan Breidenbach on 23.06.22
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCANetworkService
import OSCAPressReleasesUI
import OSCAPressReleases
import UIKit
import SwiftSoup

extension AppDI {
  final class OSCAPressReleasesUIDI {
    /**
     `OSCAPressReleasesUIDI.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let networkService  : OSCANetworkService
      let userDefaults    : UserDefaults
      let deeplinkScheme: String
    }// end struct Dependencies
    
    private let dependencies: Dependencies
    
    var pressReleasesFlow: OSCAPressReleasesFlowCoordinator?
    var dataModule: OSCAPressReleases?
    
    init(dependencies: Dependencies){
      self.dependencies = dependencies
    }// end init
    
    // MARK: - Feature Module dependencies
    func makeOSCAPressReleasesDependencies() -> OSCAPressReleasesDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let dataModuleDependencies: OSCAPressReleasesDependencies = OSCAPressReleasesDependencies(appStoreURL: AppDI.Environment.appStoreUrl, networkService: self.dependencies.networkService,
                                                                                                userDefaults: self.dependencies.userDefaults)
      return dataModuleDependencies
    }// end func make
    
    // MARK: - Feature Module
    /// singleton data module
    func makeOSCAPressReleasesModule() -> OSCAPressReleases {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let pressReleasesModule = dataModule {
        return pressReleasesModule
      } else {
        let pressReleasesModule = OSCAPressReleases.create(with: makeOSCAPressReleasesDependencies())
        dataModule = pressReleasesModule
        return pressReleasesModule
      }// end if
    }// end func makeOSCAPressReleases
    
    // MARK: - Feature UI Module html content modifier
    func makeOSCAPressReleasesUIHtmlContentModifier() -> ((String) -> String) {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return { content in
        var htmlContent = content
        do {
          let doc = try SwiftSoup.parseBodyFragment(htmlContent)
          try doc.select("h5").remove()
          try doc.select("p").first()?.remove()
          htmlContent = try doc.outerHtml()
        } catch let Exception.Error(_, message) {
          print(message)
          htmlContent = content
        } catch {
          print("error")
          htmlContent = content
        }
        return htmlContent
      }
    }
    
    // MARK: - Feature UI Module shadow settings
    func makeOSCAPressReleasesUIShadowSettings() -> OSCAShadowSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAShadowSettings(opacity: 0.2,
                                radius: 10,
                                offset: CGSize(width: 0, height: 2))
    }
    
    // MARK: - Feature UI Module Color settings
    func makeOSCAPressReleasesUIColorSettings() -> OSCAColorSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAColorSettings()
    }// end func make OSCAColorSettings for press releases ui
    
    // MARK: - Feature UI Module Type face settings
    func makeOSCAPressReleasesUIFontSettings() -> OSCAFontSettings {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAFontSettings()
    }// end func make OSCAFontSettings for press releases ui
    
    // MARK: - Feature UI Module Placeholder Image
    func makeOSCAPressReleasesUIPlaceholderImage() -> (image: UIImage, color: UIColor?)? {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      guard let image = UIImage(named: "placeholder_image",
                                in: OSCASolingen.bundle,
                                with: .none)
      else { return nil }
      return (image, nil)
    }
    
    // MARK: - Feature UI Module Config
    func makeOSCAPressReleasesUIConfig() -> OSCAPressReleasesUIConfig {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAPressReleasesUIConfig(title: "OSCAPressReleasesUI",
                                       shadowSettings: makeOSCAPressReleasesUIShadowSettings(),
                                       showImage: true,
                                       showReadingTime: true,
                                       cornerRadius: 10.0,
                                       placeholderImage: makeOSCAPressReleasesUIPlaceholderImage(),
                                       fontConfig: makeOSCAPressReleasesUIFontSettings(),
                                       colorConfig: makeOSCAPressReleasesUIColorSettings())
    }// end func make OSCAPressReleasesUIConfig
    
    // MARK: - Feature UI Module dependencies
    func makeOSCAPressReleasesUIModuleDependencies() -> OSCAPressReleasesUIDependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      return OSCAPressReleasesUIDependencies(dataModule: makeOSCAPressReleasesModule() ,
                                             moduleConfig: makeOSCAPressReleasesUIConfig())
    }// end func make OSCAPressReleasesUI dependencies
    
    // MARK: - Feature UI Module
    func makeOSCAPressReleasesUIModule() -> OSCAPressReleasesUI {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      return OSCAPressReleasesUI.create(with: makeOSCAPressReleasesUIModuleDependencies())
    }// end func makePressReleaseModule
  }// end final class OSCAPressReleasesUIDI
}// end extension public final class AppDI

// MARK: - Feature UI Module Flow Coordinators
extension AppDI.OSCAPressReleasesUIDI {
  /// singleton `Coordinator`
  func makeOSCAPressReleasesFlowCoordinator(router: Router) -> OSCAPressReleasesFlowCoordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let pressReleasesFlow = pressReleasesFlow {
      return pressReleasesFlow
    } else {
      let flow = makeOSCAPressReleasesUIModule()
        .getPressReleasesFlowCoordinator(router: router)
      return flow
    }// end if
  }// end func make module flow coordinator
}// end extension final class OSCAPressReleasesUIDI
