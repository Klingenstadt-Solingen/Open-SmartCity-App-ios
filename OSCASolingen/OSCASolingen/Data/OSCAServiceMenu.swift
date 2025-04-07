//
//  OSCAServiceMenu.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.06.22.
//  Reviewed by Stephan Breidenbach on 23.06.22
//

import Combine
import Foundation
import OSCAEssentials
import OSCANetworkService

public struct OSCAServiceMenu {
  public struct Dependencies {
    let networkService: OSCANetworkService
    let userDefaults: UserDefaults
  } // end public struct OSCAServiceMenu.Dependencies
  
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  
  public init(dependencies: OSCAServiceMenu.Dependencies) {
    networkService = dependencies.networkService
    userDefaults = dependencies.userDefaults
  } // end public init with dependencies
} // end public struct OSCAServiceMenu

// MARK: - Data access

extension OSCAServiceMenu {
  public typealias OSCAServiceMenuPublisher = AnyPublisher<[ServiceMenu], OSCASGError>
  /// Fetches all townhall data from parse server in background
  /// - Parameter limit: Limits the amount of events that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: Publisher with a list of all service menu data on the `Output` and possible `OSCANetworkError`s on the `Fail`channel
  public func fetchAllServiceMenu(limit: Int = 100,
                                  query: [String: String] = [:]) -> AnyPublisher<[ServiceMenu], OSCANetworkError> {
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
    
    return networkService.fetch(OSCAClassRequestResource<ServiceMenu>
      .serviceMenu(baseURL: networkService.config.baseURL,
                   headers: networkService.config.headers,
                   query: parameters))
    // fetch service data in background
    .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
    .eraseToAnyPublisher()
  } // end public fetchAllServiceData
  
  /// Fetches all townhall data from parse server without query in background
  /// - Parameter maxCount: maximum amount of townhall data that get downloaded from server
  /// - Returns: Publisher with a list of all service menu data on the `Output` and possible `OSCASGError`s on the `Fail`channel
  public func fetchAllServiceMenu(maxCount: Int = 100) -> OSCAServiceMenuPublisher {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return fetchAllServiceMenu(limit: maxCount, query: [:])
      .mapError(OSCASGError.map(_:))
      .eraseToAnyPublisher()
  } // end public func fetchAllServiceMenu
  
  func fetchImage(objectId: String, baseURL: URL, fileName: String, mimeType: String) -> AnyPublisher<Result<ServiceMenuItemImageData, Error>, Never> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var headers = networkService.config.headers
    if let sessionToken = userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }
    return networkService
      .fetch(OSCAImageDataRequestResource<ServiceMenuItemImageData>
        .serviceMenuItemImageData(objectId: objectId, baseURL: baseURL, fileName: fileName, mimeType: mimeType))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<ServiceMenuItemImageData, Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }
} // end extension OSCAServiceMenu

// MARK: - static mutating functions

extension OSCAServiceMenu {}

public struct ServiceMenuItemImageData: OSCAImageData {
  public var imageData: Data?
  public var objectId: String?
  
  public init(objectId: String, imageData: Data) {
    self.imageData = imageData
    self.objectId = objectId
  }
  
  public static func < (lhs: ServiceMenuItemImageData, rhs: ServiceMenuItemImageData) -> Bool {
    let lhsImageData = lhs.imageData
    let rhsImageData = rhs.imageData
    if nil != lhsImageData {
      if nil != rhsImageData {
        return lhsImageData!.count < rhsImageData!.count
      } else {
        return false
      }
    } else {
      if nil != rhsImageData {
        return false
      } else {
        return true
      }
    }
  }
}

extension OSCAImageDataRequestResource {
  /// OSCAImageFileDataRequestResource for service menu images
  /// - Parameters:
  ///    - objectId: The id of a ServiceMenu
  ///    - baseURL: The URL to the file
  ///    - fileName: The name of the file
  ///    - mimeType: The filename extension
  /// - Returns: A ready to use OSCAImageFileDataRequestResource
  static func serviceMenuItemImageData(objectId: String, baseURL: URL, fileName: String, mimeType: String) -> OSCAImageDataRequestResource<ServiceMenuItemImageData> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return OSCAImageDataRequestResource<ServiceMenuItemImageData>(
      objectId: objectId,
      baseURL: baseURL,
      fileName: fileName,
      mimeType: mimeType)
  }
}
