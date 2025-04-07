//
//  OSCAAppointmentsError.swift
//  OSCAAppointments
//
//  Created by Ömer Kurutay on 19.02.23.
//

import Foundation

public enum OSCAAppointmentsError: Swift.Error, CustomStringConvertible {
  case networkInvalidRequest
  case networkInvalidResponse
  case networkDataLoading(statusCode: Int, data: Data)
  case networkJSONDecoding(error: Error)
  case networkIsInternetConnectionFailure
  case networkError
  case appointmentsViewModelAppointmentsFetching
  
  public var description: String {
    switch self {
    case .networkInvalidRequest:
      return "There is a network Problem: invalid request!"
    case .networkInvalidResponse:
      return "There is a network Problem: invalid response!"
    case let .networkDataLoading(statusCode, data):
      return "There is a network Problem: data loading failed with status code \(statusCode): \(data)"
    case let .networkJSONDecoding(error):
      return "There is a network Problem: JSON decoding: \(error.localizedDescription)"
    case .networkIsInternetConnectionFailure:
      return "There is a network Problem: Internet connection failure!"
    case .networkError:
      return "There is an unspecified network Problem!"
    case .appointmentsViewModelAppointmentsFetching:
      return "Error fetching appointment items!"
    }
  }
}

extension OSCAAppointmentsError: Equatable{
  public static func == (lhs: OSCAAppointmentsError, rhs: OSCAAppointmentsError) -> Bool {
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
    default:
      return false
    }
  }
}
