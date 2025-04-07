//
//  OSCASGError.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.06.22.
//

import Foundation
import OSCANetworkService
import OSCAEssentials

public enum OSCASGError: Swift.Error, CustomStringConvertible {
  case networkInvalidRequest
  case networkInvalidResponse
  case networkDataLoading(statusCode: Int, data: Data)
  case networkJSONDecoding(error: Error)
  case networkIsInternetConnectionFailure
  case networkError
  case parseError(msg: String)
  case parseInstallationCorrupt
  case appInit(msg: String)
  case noDefaultLocation
}// end public enum OSCASGError

extension OSCASGError {
  public var description: String {
    switch self {
    case .networkInvalidRequest:
      // return "There is a network Problem: invalid request!"
      return "oscasgerror_networkInvalidRequest".localized
    case .networkInvalidResponse:
      return "oscasgerror_networkInvalidResponse".localized
    case let .networkDataLoading(statusCode, _):
      //return "There is a network Problem: data loading failed with status code \(statusCode): \(data)"
      return "There is a network Problem: data loading failed with status code: %d".localizeWithFormat(arguments: statusCode)
    case let .networkJSONDecoding(error):
      return "oscasgerror_networkJSONDecoding %@".localizeWithFormat(arguments: error.localizedDescription)
    case .networkIsInternetConnectionFailure:
      return "oscasgerror_networkInternetConnection".localized
    case .networkError:
      return "oscasgerror_networkUnspecified".localized
    case let .parseError(msg):
      return "oscasgerror_parseErrorMessage %@".localizeWithFormat(arguments: msg)
    case .parseInstallationCorrupt:
      return "oscasgerror_parseInstallationCorrup".localized
    case let .appInit(msg):
      return "oscasgerror_applicationInitialization %@".localizeWithFormat(arguments: msg)
    case .noDefaultLocation:
      return "oscasgerror_noDefaultLocation".localized
    }// end switch case
  }// end var description
}// end extension OSCASGError

// MARK: - Error Mapping
extension OSCASGError {
  public static func map(_ networkError: OSCANetworkError) -> OSCASGError {
    switch networkError {
    case .invalidRequest:
      return .networkInvalidRequest
    case .invalidResponse:
      return .networkInvalidResponse
    case .dataLoadingError(let statusCode, let data):
      return .networkDataLoading(statusCode: statusCode, data: data)
    case .jsonDecodingError(let error):
      return .networkJSONDecoding(error: error)
    case .isInternetConnectionError:
      return .networkIsInternetConnectionFailure
    }// end switch case
  }// end public static func map OSCANetworkError
}// end extension OSCASGError

extension OSCASGError: Equatable{
  public static func == (lhs: OSCASGError, rhs: OSCASGError) -> Bool {
    switch (lhs, rhs) {
    case (.networkInvalidRequest, .networkInvalidRequest):
      return true
    case (.networkInvalidResponse,.networkInvalidResponse):
      return true
    case (.networkDataLoading(let statusCodeLhs, let dataLhs),.networkDataLoading(let statusCodeRhs, let dataRhs)):
      let statusCode = statusCodeLhs == statusCodeRhs
      let data = dataLhs == dataRhs
      return statusCode && data
    case (networkJSONDecoding(_),networkJSONDecoding(_)):
      return true
    case (.networkIsInternetConnectionFailure,.networkIsInternetConnectionFailure):
      return true
    case (.networkError,.networkError):
      return true
    case (.parseError(let msgLhs), .parseError(let msgRhs)):
      let msg = msgLhs == msgRhs
      return msg
    case (.parseInstallationCorrupt, .parseInstallationCorrupt):
      return true
    case (.appInit(let msgLhs), .appInit(let msgRhs)):
      let msg = msgLhs == msgRhs
      return msg
    case (.noDefaultLocation, .noDefaultLocation):
      return true
    default:
      return false
    }// switch case
  }// public static func ==
}// end extension public enum OSCASGError

extension String {
  func localizeWithFormat(arguments: CVarArg...) -> String{
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return String(format: self.localized, arguments: arguments)
  }// end func localizeWithFormat
  
  var localized: String{
    let bundlePrefix: String = "de.osca.solingen.core"
    var bundle: Bundle?
#if SWIFT_PACKAGE
    bundle = Bundle.module
#else
    bundle = Bundle(identifier: bundlePrefix)
#endif
    if let bundle = bundle {
      return bundle.localizedString(forKey: self,
                                    value: nil,
                                    table: /*"StandardLocalizations"*/ nil)
    } else {
      return Bundle.main.localizedString(forKey: self,
                                         value: nil,
                                         table: /*"StandardLocalizations"*/ nil)
    }// end if
  }// end var localized
}// end extension String

extension OSCASGError: CategorizedError {
  public var category: ErrorCategory {
    switch self {
    case .networkInvalidRequest:
      return .retryable
    case .networkInvalidResponse:
      return .retryable
    case .networkDataLoading:
      return .retryable
    case .networkJSONDecoding:
      return .nonRetryable
    case .networkIsInternetConnectionFailure:
      return .retryable
    case .networkError:
      return .retryable
    case .parseError:
      return .retryable
    case .parseInstallationCorrupt:
      return .retryable
    case .appInit:
      return .nonRetryable
    case .noDefaultLocation:
      return .nonRetryable
    }// end switch case
  }// end var category
}// end extension enum OSCASGError
