//
//  OSCABottomBar.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.08.22.
//

import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public struct OSCABottomBar {
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  let deeplinkScheme: String
  
  public init(dependencies: OSCABottomBar.Dependencies) {
    self.networkService = dependencies.networkService
    self.userDefaults = dependencies.userDefaults
    self.deeplinkScheme = dependencies.deeplinkScheme
  } // end public init with dependencies
} // end public struct OSCABottomBar

extension OSCABottomBar {
  public struct Dependencies {
    let networkService: OSCANetworkService
    let userDefaults: UserDefaults
    let deeplinkScheme: String
  } // end public struct OSCABottomBar.Dependencies
}// end extension public struct OSCABottomBar

// MARK: - Data access

extension OSCABottomBar {
  public typealias OSCABottomBarPublisher = AnyPublisher<[OSCABottomBar.BottomBar], OSCASGError>
  public typealias OSCAHomeTabViewModelPublisher = AnyPublisher<[HomeTabItemViewModel], OSCASGError>
  /// Fetches all bottom bar data  from parse server in background
  /// - Parameter limit: Limits the amount of events that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: Publisher with a list of all bottom bar data on the `Output` and possible `OSCANetworkError`s on the `Fail`channel
  public func fetchAllBottomBarItems(limit: Int = 100,
                                     query: [String: String] = [:]) -> AnyPublisher<[OSCABottomBar.BottomBar], OSCANetworkError> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard limit > 0 else {
      return Empty(completeImmediately: true).eraseToAnyPublisher()
    } // end guard
    
    var parameters = query
    parameters["limit"] = "\(limit)"
    
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
    return networkService.fetch(OSCAClassRequestResource<OSCABottomBar.BottomBar>
      .bottomBar(baseURL: networkService.config.baseURL,
                 headers: networkService.config.headers,
                 query: parameters))
    // fetch service data in background
    .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
    .eraseToAnyPublisher()
  } // end public fetchAllServiceData
  
  /// Fetches all bottom bar  data from parse server without query in background
  /// - Parameter maxCount: maximum amount of bottom bar data that get downloaded from server
  /// - Returns: Publisher with a list of all bottom bar data on the `Output` and possible `OSCASGError`s on the `Fail`channel
  public func fetchAllBottomBarItems(maxCount: Int = 100) -> OSCABottomBarPublisher {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return fetchAllBottomBarItems(limit: maxCount, query: [:])
      .mapError(OSCASGError.map(_:))
      .eraseToAnyPublisher()
  } // end public func fetchAllBottomBarItems
} // end extension OSCABottomBar

extension OSCABottomBar {}

