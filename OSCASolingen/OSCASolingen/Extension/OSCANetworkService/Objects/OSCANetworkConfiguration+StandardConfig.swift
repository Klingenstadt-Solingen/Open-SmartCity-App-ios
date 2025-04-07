//
//  OSCANetworkConfiguration+StandardConfig.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 13.06.22.
//

import Foundation
import OSCANetworkService

public extension OSCANetworkConfiguration{
  private enum Environment {
    enum Keys {
      enum Plist {
        static let parseAPIRootURL           = "PARSE_API_ROOT_URL"          //
        static let parseAPIRootURL_DEV       = "PARSE_API_ROOT_URL_DEV"      //
        static let parseAPIKey               = "PARSE_API_KEY"               //
        static let parseAPIKey_DEV           = "PARSE_API_KEY_DEV"           //
        static let parseAPIApplicationID     = "PARSE_API_APPLICATION_ID"    //
        static let parseAPIApplicationID_DEV = "PARSE_API_APPLICATION_ID_DEV"//
        static let environment               = "ENVIRONMENT"                 //
      }// end enum Plist
    }// end enum Keys
    
    /**
     
     */
    private static let infoDictionary: [String: Any] = {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      guard let dict = Bundle.main.infoDictionary else {
        fatalError("Plist file not found")
      }// end guard
      return dict
    }()// end private static let apiDictionary
    
    /**
     Decode Parse  API-key `String` from Plist
     */
    public static let parseAPIKey: String = {
      guard let parseAPIKeyString = OSCANetworkConfiguration.Environment.infoDictionary[Keys.Plist.parseAPIKey] as? String else {
        fatalError("Parse API Key not set in plist for this environment")
      }// end guard
      return parseAPIKeyString
    }()// end static let parseAPIKey
    
    /**
     Decode Dev-Parse  API-key `String` from Plist
     */
    public static let parseDevAPIKey: String = {
      guard let parseDevAPIKeyString = OSCANetworkConfiguration.Environment.infoDictionary[Keys.Plist.parseAPIKey_DEV] as? String else {
        fatalError("Parse Dev API Key not set in plist for this environment")
      }// end guard
      return parseDevAPIKeyString
    }()// end static let parseDevAPIKey
    
    /**
     Decode Parse API application ID `String`from Plist
     */
    public static let parseAPIApplicationID: String = {
      guard let parseAPIApplicationIDString = OSCANetworkConfiguration.Environment.infoDictionary[Keys.Plist.parseAPIApplicationID] as? String else {
        fatalError("Parse API Application ID not set in plist for this environment")
      }// end guard
      return parseAPIApplicationIDString
    }()// end static let parseAPIApplicationID
    
    /**
     Decode Dev-Parse API application ID `String`from Plist
     */
    public static let parseDevAPIApplicationID: String = {
      guard let parseDevAPIApplicationIDString = Environment.infoDictionary[Keys.Plist.parseAPIApplicationID_DEV] as? String else {
        fatalError("Parse Dev API Application ID not set in plist for this environment")
      }// end guard
      return parseDevAPIApplicationIDString
    }()// end static let parseDevAPIApplicationID
    
    /**
     Decode Parse API root URL `String`from Plist
     */
    public static let parseAPIRootURL: String = {
      guard let parseAPIRootURLString = Environment.infoDictionary[Keys.Plist.parseAPIRootURL] as? String else {
        fatalError("Parse API Root URL not set in plist for this environment")
      }// end guard
      return parseAPIRootURLString
    }()// end static let parseRootURL
    
    /**
     Decode Dev-Parse API root URL `String`from Plist
     */
    public static let parseDevAPIRootURL: String = {
      guard let parseDevAPIRootURLString = Environment.infoDictionary[Keys.Plist.parseAPIRootURL_DEV] as? String else {
        fatalError("Parse Dev API Root URL not set in plist for this environment")
      }// end guard
      return parseDevAPIRootURLString
    }()// end static let parseRootURL
    
  }// end private enum Environment
  
  /// readymade parse dev network config
  static let parseDevConfig: OSCANetworkConfiguration = {
    guard let baseURL: URL = URL(string: OSCANetworkConfiguration.Environment.parseDevAPIRootURL)
    else {
      fatalError("Parse Dev API Root URL is no valid URL")
    }// end guard
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": OSCANetworkConfiguration.Environment.parseDevAPIKey,
      "X-PARSE-APPLICATION-ID": OSCANetworkConfiguration.Environment.parseDevAPIApplicationID
    ]// end headers
    return OSCANetworkConfiguration(baseURL: baseURL,
                                    headers: headers,
                                    session: URLSession.shared)
  }()// end static let parseDevConfig
  
  /// readymade parse production network config
  static let parseProductionConfig: OSCANetworkConfiguration = {
    guard let baseURL: URL = URL(string: OSCANetworkConfiguration.Environment.parseAPIRootURL)
    else {
      fatalError("Parse API Root URL is no valid URL")
    }// end guard
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": OSCANetworkConfiguration.Environment.parseAPIKey,
      "X-PARSE-APPLICATION-ID": OSCANetworkConfiguration.Environment.parseAPIApplicationID
    ]// end headers
    return OSCANetworkConfiguration(baseURL: baseURL,
                                    headers: headers,
                                    session: URLSession.shared)
  }()// end static let parseProductionConfig
}// end public extension struct OSCANetworkConfiguration
