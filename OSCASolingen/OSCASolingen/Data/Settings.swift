//
//  Settings.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 19.07.22.
//

import OSCAEssentials
import OSCANetworkService
import OSCAWaste
import OSCAWeather
import Foundation
import Combine

struct Settings {
  struct Dependencies {
    let networkService: OSCANetworkService
    let userDefaults: UserDefaults
    let launchData: Launch
  }// end struct Dependencies
  
  private let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  let launchData: Launch
  
  private var installation: ParseInstallation {
    return self.launchData.parseInstallation
  }// end var installation
  
  init(dependencies: Settings.Dependencies) {
    self.networkService = dependencies.networkService
    self.userDefaults = dependencies.userDefaults
    self.launchData = dependencies.launchData
  }// end init
}// end struct Settings

// MARK: - Data access weather
extension Settings {
  
  func getUserWeatherStationId() -> String? {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return userDefaults.getOSCAWeatherObserved()
  }// end func getUserWeatherStationId
  
  func getWasteUserAddress() throws -> OSCAWasteAddress {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return try userDefaults.getOSCAWasteAddress()
  }// end func getWasteUserAddress
  
  /// Downloads all config parameters declared in `LegallyParseConfig` from parse-server
  public func getParseConfigParams() -> AnyPublisher<LegallyParseConfig, OSCASGError> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
    
    let publisher: AnyPublisher<LegallyParseConfig,OSCANetworkError> = self.networkService
      .fetch(OSCAConfigRequestResource<LegallyParseConfig>
        .legallyParseConfig(baseURL: self.networkService.config.baseURL,
                            headers: self.networkService.config.headers))
    return publisher
      .mapError(OSCASGError.map(_:))
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }// end public func getPArseConfigParams
}// end extension struct Settings

// MARK: - Installation
extension Settings {
  var parseRootURL: String? {
    return self.networkService.config.baseURL.absoluteString
  }// end var parseRootURL
  
  var installationId: String? {
    return self.launchData.parseInstallation.installationId
  }// end var installation id
  
  var appVersion: String? {
    return self.launchData.parseInstallation.appVersion
  }// end var appVersion
  
  var appIdentifier: String? {
    return self.launchData.parseInstallation.appIdentifier
  }// end var appIdentifier
}// end extension struct Settings
