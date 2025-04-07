//
//  AppDI+Config.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 28.11.23.
//

import Foundation
import OSCAEssentials

extension AppDI {
  /// centralized class where external properties from `Info.plist` are accessable
  public final class Config {
    public init() {}
  }// end final class Config
}// end extension AppDI

extension AppDI {
  // swiftlint:disable nesting missing_docs
  public enum Environment {
    // MARK: - Keys
    public enum Keys {
      // swiftlint: disable empty_commented_line
      public enum Plist {
        public static let defaultGeoPointLatitude  = "DEFAULT_GEO_POINT_LATITUDE"  //
        public static let defaultGeoPointLongitude = "DEFAULT_GEO_POINT_LONGITUDE" //
        public static let appStoreUrl              = "APP_STORE_URL"               //
        public static let parseAPIRootURL          = "PARSE_API_ROOT_URL"          //
        public static let parseAPIKey              = "PARSE_API_KEY"               //
        public static let parseRESTAPIKey          = "PARSE_REST_API_KEY"          //
        public static let parseMasterAPIKey        = "PARSE_MASTER_API_KEY"        //
        public static let parseAPIApplicationID    = "PARSE_API_APPLICATION_ID"    //
        public static let devParseAPIRootURL       = "PARSE_API_ROOT_URL_DEV"      //
        public static let devParseRESTAPIKey       = "PARSE_REST_API_KEY_DEV"      //
        public static let devParseMasterAPIKey     = "PARSE_MASTER_API_KEY_DEV"    //
        public static let devParseAPIApplicationID = "PARSE_API_APPLICATION_ID_DEV"//
        public static let devParseAPIKey           = "PARSE_API_KEY_DEV"           //
        public static let imageAPIRootURL          = "ImageBaseURL"                //
        public static let launchScreenTitle        = "LaunchScreenImageName"       //
        public static let splashAnimationName      = "SplashAnimationName"         //
        public static let launchScreenImageName    = "LaunchScreenImageName"       //
        public static let homeTabItems             = "homeTabItems"                //
        public static let deeplinkScheme           = "DEEPLINK_SCHEME"             //
        public static let environment              = "ENVIRONMENT"                 //
        public static let sentryDSN                = "SENTRY_DSN"                  //
        public static let sentryEnabled            = "SENTRY_ENABLED"              //
        public static let matomoUrl                = "MATOMO_URL"                  //
        public static let matomoEnabled            = "MATOMO_ENABLED"              //
        public static let matomoSiteId             = "MATOMO_SITE_ID"              //
        public static let politicsURL              = "POLITICS_URL"                //
      }// end enum Plist
      // swiftlint: enable empty_commented_line
    }// end enum Keys
    
    // MARK: - Plist
    private static func resolvePath(for resourceName: String) -> String? {
      guard !resourceName.isEmpty
      else { return nil }
      //let bundle = Bundle(for: AppDI.self)
      //let bundle = Bundle.main
      if let filePath = Bundle.main.path(forResource: resourceName,
                                     ofType: "plist"){
        return filePath
      }
      else if let filePath = Bundle(for: OSCASolingen.DIContainer.self).path(forResource: resourceName,
                                                          ofType: "plist") {
        return filePath
      }
      else { return nil }
    }// end func resolvePath for resourceName
    /**
     [`Data(contentsOf:)`](https://sarunw.com/posts/how-to-read-plist-file/)
     */
    public static var apiData: Data? {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      let resourceName = "API_Release"
      // configure secrets
      var resolvedFilePath = resolvePath(for: resourceName)
      guard let resolvedFilePath = resolvedFilePath
      else { fatalError("\(resourceName).plist not found") }
      let pathURL = URL(fileURLWithPath: resolvedFilePath)
      do {
        let plistData = try Data(contentsOf: pathURL)
        return plistData
      } catch {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
      }// end do catch
#warning("TODO: fatalError")
      fatalError("No data from \(resourceName).plist")
    }// end public static let apiData
    
    public static var apiDataDev: Data? {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      let resourceName = "API_Develop"
      // configure secrets
      var resolvedFilePath = resolvePath(for: resourceName)
      guard let resolvedFilePath = resolvedFilePath
      else {
#warning("TODO: fatalError")
        fatalError("\(resourceName).plist not found")
      }
      let pathURL = URL(fileURLWithPath: resolvedFilePath)
      do {
        let plistData = try Data(contentsOf: pathURL)
        return plistData
      } catch {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
      }// end do catch
#warning("TODO: fatalError")
      fatalError("No data from \(resourceName).plist")
    }// end public static var apiData
    
    public static var apiDictionary: [String: Any] {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      var dict: [String: Any]?
      guard let apiData = AppDI.Environment.apiData
      else {
#warning("TODO: fatalError")
        fatalError("No data for serialization!")
      }
      do {
        dict        = try PropertyListSerialization.propertyList(from: apiData,
                                                                 options: [],
                                                                 format: nil) as? [String: Any]
      } catch {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
      }// end do catch
      guard let dict = dict
      else { return [:] }// end guard
      return dict
    }// end public static var apiDictionary
    
    public static var apiDictionaryDev: [String: Any] {
#if DEBUG
      print("\(String(describing: Self.self)): \(#function)")
#endif
      var dict: [String: Any]?
      guard let apiData = AppDI.Environment.apiDataDev
      else {
#warning("TODO: fatalError")
        fatalError("No data for serialization!")
      }
      do {
        dict        = try PropertyListSerialization.propertyList(from: apiData,
                                                                 options: [],
                                                                 format: nil) as? [String: Any]
      } catch {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
      }// end do catch
      guard let dict = dict
      else { return [:] }// end guard
      return dict
    }// end private static let apiDictionaryDev
    
    // MARK: - Plist values
    public static var defaultLocation: OSCAGeoPoint? {
      let dict: [String: Any]
#if DEBUG
      dict = apiDictionaryDev
#else
      dict = apiDictionary
#endif
      let defaultGeoPointLatitudeString = dict[Keys.Plist.defaultGeoPointLatitude] as? String
      let defaultGeoPointLongitudeString = dict[Keys.Plist.defaultGeoPointLongitude] as? String
      return OSCAGeoPoint(latString: defaultGeoPointLatitudeString,
                          lonString: defaultGeoPointLongitudeString)
    }
    
    /// Decode AppStore URL as `String`from Plist
    public static var appStoreUrl: URL? {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      let appStoreUrlString = dict[Keys.Plist.appStoreUrl] as? String
      let appStoreURL = URL(string: appStoreUrlString ?? "")
      return appStoreURL
    }// end public static var appStoreURL
    
    /**
     Decode Parse API root URL `String`from Plist
     */
    public static var parseAPIRootURL: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseAPIRootURLString = dict[Keys.Plist.parseAPIRootURL] as? String else {
#warning("TODO: fatalError")
        fatalError("Parse API Root URL not set in plist for this environment")
      }// end guard
      return parseAPIRootURLString
    }// end public static var parseRootURL
    
    /**
     Decode Parse  API-key `String` from Plist
     */
    public static var parseAPIKey: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseAPIKeyString = dict[Keys.Plist.parseAPIKey] as? String else {
#warning("TODO: fatalError")
        fatalError("Parse API Key not set in plist for this environment")
      }// end guard
      return parseAPIKeyString
    }// end public static var parseAPIKey
    
    /**
     Decode Parse REST- API-key `String` from Plist
     */
    public static var parseRESTAPIKey: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseRESTAPIKeyString = dict[Keys.Plist.parseRESTAPIKey] as? String else {
#warning("TODO: fatalError")
        fatalError("Parse REST API Key not set in plist for this environment")
      }// end guard
      return parseRESTAPIKeyString
    }// end public static var parseRESTAPIKey
    
    /**
     Decode Parse Master- API-key `String` from Plist
     */
    public static var parseMasterAPIKey: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseMasterAPIKeyString = dict[Keys.Plist.parseMasterAPIKey] as? String else {
#warning("TODO: fatalError")
        fatalError("Parse Master API Key not set in plist for this environment")
      }// end guard
      return parseMasterAPIKeyString
    }// end public static var parseMasterAPIKey
    
    /**
     Decode Parse API application ID `String`from Plist
     */
    public static var parseAPIApplicationID: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseAPIApplicationIDString = dict[Keys.Plist.parseAPIApplicationID] as? String else {
#warning("TODO: fatalError")
        fatalError("Parse API Application ID not set in plist for this environment")
      }// end guard
      return parseAPIApplicationIDString
    }// end public static var parseAPIApplicationID
    
    /**
     Decode developer Parse API root URL `String`from Plist
     */
    public static var parseAPIRootURLDev: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseAPIRootURLDevString = dict[Keys.Plist.devParseAPIRootURL] as? String else {
#warning("TODO: fatalError")
        fatalError("developer Parse API Root URL not set in plist for this environment")
      }// end guard
      return parseAPIRootURLDevString
    }// end static var parseRootURL
    
    /**
     Decode developer Parse REST API Key `String`from Plist
     */
    public static var parseRESTAPIKeyDev: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseRESTAPIKeyDevString = dict[Keys.Plist.devParseRESTAPIKey] as? String else {
#warning("TODO: fatalError")
        fatalError("developer Parse REST API key not set in plist for this environment")
      }// end guard
      return parseRESTAPIKeyDevString
    }// end public static var parseRESTAPIKeyDev
    
    /**
     Decode developer Parse master API Key `String`from Plist
     */
    public static var parseMasterAPIKeyDev: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseMasterAPIKeyDevString = dict[Keys.Plist.devParseMasterAPIKey] as? String else {
#warning("TODO: fatalError")
        fatalError("developer Parse master API key not set in plist for this environment")
      }// end guard
      return parseMasterAPIKeyDevString
    }// end public static var parseMasterAPIKeyDev
    
    /**
     Decode developer Parse API application ID `String`from Plist
     */
    public static var parseAPIApplicationIDDev: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseAPIApplicationIDDevString = dict[Keys.Plist.devParseAPIApplicationID] as? String else {
#warning("TODO: fatalError")
        fatalError("developer Parse API Application ID not set in plist for this environment")
      }// end guard
      return parseAPIApplicationIDDevString
    }// end public static var parseAPIApplicationID
    
    /**
     Decode developer Parse  API-key `String` from Plist
     */
    public static var parseAPIKeyDev: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let parseAPIKeyDevString = dict[Keys.Plist.devParseAPIKey] as? String else {
#warning("TODO: fatalError")
        fatalError("developer Parse API Key not set in plist for this environment")
      }// end guard
      return parseAPIKeyDevString
    }// end public static var parseAPIKey
    
    public static var deeplinkScheme: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let deeplinkSchemaString = dict[Keys.Plist.deeplinkScheme] as? String else {
#warning("TODO: fatalError")
        fatalError("application deeplink scheme Key not set in plist for this environment")
      }
      return deeplinkSchemaString
    }// end public static var deeplinkScheme
    
    /**
     Decode Image API root URL `String`from Plist
     */
    public static var imageAPIRootURL: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let imageAPIRootURLNN = dict[Keys.Plist.imageAPIRootURL] as? String
      else {
#warning("TODO: fatalError")
        fatalError("images ApiBaseURL must not be empty in plist")
      }// end guard
      return imageAPIRootURLNN
    }// end public static var imageAPIRootURL
    
    /**
     Decode launch screen image name `String`from Plist
     */
    public static var launchScreenImageName: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let launchScreenImageNameNN = dict[Keys.Plist.launchScreenImageName] as? String
      else {
#warning("TODO: fatalError")
        fatalError("launch screen image name must not be empty in plist")
      }// end guard
      return launchScreenImageNameNN
    }// end public static var launchScreenImageName
    
    /**
     Decode splash animation name `String`from Plist
     */
    public static var splashAnimationName: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let splashAnimationNameNN = dict[Keys.Plist.splashAnimationName] as? String
      else {
#warning("TODO: fatalError")
        fatalError("Splash animation name must not be empty in plist")
      }// end guard
      return splashAnimationNameNN
    }// end public static var splashAnimationName
    
    /**
     Decode launch screen title `String`from Plist
     */
    public static var launchSreenTitle: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let launchScreenTitleNN = dict[Keys.Plist.launchScreenTitle] as? String
      else {
#warning("TODO: fatalError")
        fatalError("launch screen title must not be empty in plist")
      }// end guard
      return launchScreenTitleNN
    }// end public static var imageAPIRootURL
    /**
     Decode environment `String` from Plist
     */
    public static var environment: String {
      let dict: [String: Any]
#if DEBUG
      dict = AppDI.Environment.apiDictionaryDev
#else
      dict = AppDI.Environment.apiDictionary
#endif
      guard let environmentString = dict[Keys.Plist.environment] as? String else {
#warning("TODO: fatalError")
        fatalError("AppDI.Environment not set in plist for this environment")
      }// end guard
      return environmentString
    }// end public static var environment
      
      public static var sentryDSN: String? {
#if DEBUG
          let dict = apiDictionaryDev
#else
          let dict = apiDictionary
#endif
          return dict[Keys.Plist.sentryDSN] as? String
      }
      
      public static var sentryEnabled: Bool {
#if DEBUG
          let dict = apiDictionaryDev
#else
          let dict = apiDictionary
#endif
          return dict[Keys.Plist.sentryEnabled] as? String == "true" && sentryDSN != nil
      }
      
      
      public static let matomoUrl: String? = {
        let dict: [String: Any]
    #if DEBUG
        dict = Environment.apiDictionaryDev
    #else
        dict = Environment.apiDictionary
    #endif
          guard let matomoUrlString = dict[Keys.Plist.matomoUrl] as? String else {
          return nil
        }
        return matomoUrlString
      }()
      
      public static let matomoEnabled: Bool = {
        let dict: [String: Any]
    #if DEBUG
        dict = Environment.apiDictionaryDev
    #else
        dict = Environment.apiDictionary
    #endif
          guard let enabledString = dict[Keys.Plist.matomoEnabled] as? String else {
          return false
        }
        return enabledString == "true"
      }()
      
      public static let matomoSiteId: String? = {
        let dict: [String: Any]
    #if DEBUG
        dict = Environment.apiDictionaryDev
    #else
        dict = Environment.apiDictionary
    #endif
          guard let siteIdString = dict[Keys.Plist.matomoSiteId] as? String else {
          return nil
        }
        return siteIdString
      }()
      
      public static let politicsURL: String? = {
        let dict: [String: Any]
    #if DEBUG
        dict = Environment.apiDictionaryDev
    #else
        dict = Environment.apiDictionary
    #endif
          guard let urlString = dict[Keys.Plist.politicsURL] as? String else {
          return nil
        }
        return urlString
      }()
  }// end public enum AppDI.Environment
}// end extension public final class AppDI

extension AppDI.Config {
  public var defaultLocation: OSCAGeoPoint? { AppDI.Environment.defaultLocation }
  public var defaultGeoPoint: (latitude: Double, longitude: Double) { (latitude: defaultLocation?.latitude ?? 51.177411, longitude: defaultLocation?.longitude ?? 7.085249) }
  public var parseMasterKey: String { AppDI.Environment.parseMasterAPIKey }
  public var parseAPIKey: String { AppDI.Environment.parseAPIKey }
  public var parseAPIBaseURL: String { AppDI.Environment.parseAPIRootURL }
  public var parseApplicationID: String { AppDI.Environment.parseAPIApplicationID }
  public var parseMasterKeyDev: String { AppDI.Environment.parseMasterAPIKeyDev }
  public var parseAPIKeyDev: String { AppDI.Environment.parseAPIKeyDev }
  public var parseAPIBaseURLDev: String { AppDI.Environment.parseAPIRootURLDev }
  public var parseApplicationIDDev: String { AppDI.Environment.parseAPIApplicationIDDev }
  public var imagesBaseURL: String { AppDI.Environment.imageAPIRootURL }
  // MARK: -LaunchScreen
  /**
   title of app's launch screen
   */
  public var launchScreenTitle: String { AppDI.Environment.launchSreenTitle }
  /**
   name of app's launch screen image
   */
  public var launchScreenImageName: String { AppDI.Environment.launchScreenImageName }
  // MARK: -SplashScreen
  /**
   filename of the json-file without suffix
   */
  public var splashAnimationName: String { AppDI.Environment.splashAnimationName }
  /**
   animation speed 1.0 <=> 100%
   */
  public var splashAnimationSpeed: Float { 1.5 }
  public var infoPlistsData: Data { AppDI.Environment.apiData ?? Data() }
  // MARK: - Device
  public var deviceUUID: String { NSUUID().uuidString }
  // MARK: - Deeplink
  public var deeplinkScheme: String { AppDI.Environment.deeplinkScheme }
}// end extension AppDI.Config

// - MARK: Equatable conformance
extension AppDI.Config: Equatable{
  public static func == (lhs: AppDI.Config, rhs: AppDI.Config) -> Bool {
    let defaultLocationEqual: Bool = rhs.defaultLocation == lhs.defaultLocation
    let defaultGeoPointEqual: Bool = lhs.defaultGeoPoint == rhs.defaultGeoPoint
    let parseAPIKeyEqual: Bool = lhs.parseAPIKey == rhs.parseAPIKey
    let parseAPIBaseURLEqual: Bool = lhs.parseAPIBaseURL == rhs.parseAPIBaseURL
    let parseApplicationIDEqual: Bool = lhs.parseApplicationID == rhs.parseApplicationID
    let parseAPIKeyDevEqual: Bool = lhs.parseAPIKeyDev == rhs.parseAPIKeyDev
    let parseAPIBaseURLDevEqual: Bool = lhs.parseAPIBaseURLDev == rhs.parseAPIBaseURLDev
    let parseApplicationIDDevEqual: Bool = lhs.parseApplicationIDDev == rhs.parseApplicationIDDev
    let imagesBaseURLEqual: Bool = lhs.imagesBaseURL == rhs.imagesBaseURL
    let launchScreenTitleEqual: Bool = lhs.launchScreenTitle == rhs.launchScreenTitle
    let launchScreenImageNameEqual: Bool = lhs.launchScreenImageName == rhs.launchScreenImageName
    let splashAnimationNameEqual: Bool = lhs.splashAnimationName == rhs.splashAnimationName
    let splashAnimationSpeedEqual: Bool = lhs.splashAnimationSpeed == rhs.splashAnimationSpeed
    let infoPlistsDataEqual: Bool = lhs.infoPlistsData == rhs.infoPlistsData
    let deviceUUIDEqual: Bool = lhs.deviceUUID == rhs.deviceUUID
    return defaultLocationEqual &&
    defaultGeoPointEqual &&
    parseAPIKeyEqual &&
    parseAPIBaseURLEqual &&
    parseApplicationIDEqual &&
    parseAPIKeyDevEqual &&
    parseAPIBaseURLDevEqual &&
    parseApplicationIDDevEqual &&
    imagesBaseURLEqual &&
    launchScreenTitleEqual &&
    launchScreenImageNameEqual &&
    splashAnimationNameEqual &&
    splashAnimationSpeedEqual &&
    infoPlistsDataEqual &&
    deviceUUIDEqual
  }// end public static func ==
}// end final class Config

extension AppDI.Config: OSCAAppConfig {}
