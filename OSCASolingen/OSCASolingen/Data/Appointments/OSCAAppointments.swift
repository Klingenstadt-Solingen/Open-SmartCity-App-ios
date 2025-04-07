//
//  OSCAAppointments.swift
//  OSCAAppointments
//
//  Created by Ömer Kurutay on 19.02.23.
//

import OSCAEssentials
import OSCANetworkService
import Foundation
import Combine

public struct OSCAAppointments: OSCAModule {
  
  var moduleDIContainer: OSCAAppointments.DIContainer!
  
  let transformError: (OSCANetworkError) -> OSCAAppointmentsError = { networkError in
    switch networkError {
    case OSCANetworkError.invalidResponse:
      return OSCAAppointmentsError.networkInvalidResponse
    case OSCANetworkError.invalidRequest:
      return OSCAAppointmentsError.networkInvalidRequest
    case let OSCANetworkError.dataLoadingError(statusCode: code, data: data):
      return OSCAAppointmentsError.networkDataLoading(statusCode: code, data: data)
    case let OSCANetworkError.jsonDecodingError(error: error):
      return OSCAAppointmentsError.networkJSONDecoding(error: error)
    case OSCANetworkError.isInternetConnectionError:
      return OSCAAppointmentsError.networkIsInternetConnectionFailure
    }
  }
  
  /// version of the module
  public var version: String = "1.0.2"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.solingen.core" // After seperating from core app "de.osca.appointments"
  
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!

  private var networkService: OSCANetworkService!

  public private(set) var userDefaults: UserDefaults
  
  public private(set) var dataCache: NSCache<NSString, NSData>
  
  /**
   create module and inject module dependencies

   ** This is the only way to initialize the module!!! **
   - Parameter moduleDependencies: module dependencies
   ```
   call: OSCAAppointments.create(with moduleDependencies)
   ```
   */
  public static func create(with moduleDependencies: OSCAAppointments.Dependencies) -> OSCAAppointments {
    var module: Self = Self(
      networkService: moduleDependencies.networkService,
      userDefaults: moduleDependencies.userDefaults,
      dataCache: moduleDependencies.dataCache)
    module.moduleDIContainer = OSCAAppointments.DIContainer(
      dependencies: moduleDependencies)
    return module
  }

  /// initializes the events module
  ///  - Parameter networkService: Your configured network service
  private init(networkService: OSCANetworkService,
               userDefaults: UserDefaults,
               dataCache: NSCache<NSString, NSData>) {
    self.networkService = networkService
    self.userDefaults = userDefaults
    self.dataCache = dataCache
    
    var bundle: Bundle?
    #if SWIFT_PACKAGE
      bundle = Bundle.module
    #else
      bundle = Bundle(identifier: bundlePrefix)
    #endif
    guard let bundle: Bundle = bundle
    else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  }
}

// MARK: - Dependencies
extension OSCAAppointments {
  public struct Dependencies {
    let networkService: OSCANetworkService
    let userDefaults: UserDefaults
    let dataCache = NSCache<NSString, NSData>()
    let analyticsModule: OSCAAnalyticsModule?

    public init(networkService: OSCANetworkService,
                userDefaults: UserDefaults,
                analyticsModule: OSCAAnalyticsModule? = nil) {
      self.networkService = networkService
      self.userDefaults = userDefaults
      self.analyticsModule = analyticsModule
    }
  }
}

// MARK: - Data access
extension OSCAAppointments {
  public typealias OSCAAppointmentPublisher = AnyPublisher<[OSCAAppointment], OSCAAppointmentsError>
  /// Fetches all OSCAAppointment items from parse server in background
  /// - Parameter maxCount: Limits the amount of OSCAAppointment items that gets downloaded from the server
  /// - Parameter query: HTTP query parameter
  /// - Returns: Publisher with a list of all OSCAAppointment items on the `Output` and possible `OSCASmartCityError`s on the `Fail`channel
  public func fetchAllAppointments(maxCount: Int = 1000, query: [String: String] = [:]) -> OSCAAppointmentPublisher {
    // limit is greater 0!
    guard maxCount > 0 else {
      // return an empty list of OSCAAppointments immediately
      return Empty(completeImmediately: true,
                   outputType: [OSCAAppointment].self,
                   failureType: OSCAAppointmentsError.self).eraseToAnyPublisher()
    }
    
    var parameters = query
    parameters["where"] = "{\"ref\": \"termin\"}"
    parameters["limit"] = "\(maxCount)"

    var headers = self.networkService.config.headers
    if let sessionToken = self.userDefaults.string(forKey: "SessionToken") {
      headers["X-Parse-Session-Token"] = sessionToken
    }

    var publisher: AnyPublisher<[OSCAAppointment], OSCANetworkError>
    publisher = self.networkService
      .fetch(OSCAClassRequestResource<OSCAAppointment>
      .appointment(baseURL: self.networkService.config.baseURL,
               headers: headers,
               query: parameters))
    
    return publisher
      .mapError(self.transformError)
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .eraseToAnyPublisher()
  }
  
  public func fetchImage(objectId: String, baseURL: URL, fileName: String, mimeType: String) -> AnyPublisher<Result<OSCAAppointmentImageData, Error>, Never> {
    return self.networkService
      .fetch(OSCAImageDataRequestResource<OSCAAppointmentImageData>
        .appointmentImageData(
          objectId: objectId,
          baseURL: baseURL,
          fileName: fileName,
          mimeType: mimeType))
      .map { .success($0) }
      .catch { error -> AnyPublisher<Result<OSCAAppointmentImageData, Error>, Never> in .just(.failure(error)) }
      .subscribe(on: OSCAScheduler.backgroundWorkScheduler)
      .receive(on: OSCAScheduler.mainScheduler)
      .eraseToAnyPublisher()
  }
}

