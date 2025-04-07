//
//  Launch.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 01.02.24.
//

import Foundation
import OSCAEssentials
import OSCANetworkService
import Combine

final class Launch: NSObject {
  struct Dependencies {
    let networkService: OSCANetworkService
    let userDefaults: UserDefaults
  }// end struct Dependencies
  let networkService: OSCANetworkService
  let userDefaults: UserDefaults
  
  @Published
  var pushStateChanged: Launch.Keys?
  
  /// initialize `Launch` data module with dependencies
  ///
  /// * try to recover parse user from `UserDefaults`
  /// * try to recover parse installation from `UserDefaults`
  /// * init `NSObject`
  /// * add notification observer
  init(dependencies: Launch.Dependencies) {
    self.networkService = dependencies.networkService
    self.userDefaults = dependencies.userDefaults
    super.init()
    addNotificationObserver()
  }// end init
  
  /// remove notification observer
  deinit {
    removeNotificationObserver()
  }// end deinit
  
  private var _parseInstallation: ParseInstallation!
  private var _parseUser: ParseUser!
}// end struct Launch

// MARK: - Data access local
extension Launch {
  /// parse installation instance
  var parseInstallation: ParseInstallation {
    /// local parse installation getter
    get {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let installation = _parseInstallation {
        return installation
      } else {
        // get installation from user defaults
        if let installation = self.userDefaults.parseInstallation,
           let _ = installation.installationId {
          self.parseInstallation = installation
          return installation
        } else {
          return recreateParseInstallation()
        }// end if
      }// end if
    }// end get
    /// local parse installation setter
    set {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      self._parseInstallation = newValue
      // persist parse installation in user defaults
      self.userDefaults.parseInstallation = newValue
    }// end set
  }// end var parseInstallation
  
  /// initialize a new `uuid`
  /// * update `parseInstallation`
  /// * update `parseUser`
  func recreateParseInstallation(with parseInstallation: ParseInstallation? = nil) -> ParseInstallation {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let installationId = UUID().uuidString.lowercased()
    var installation = ParseInstallation(installationId: installationId)
    if let withParseInstallation = parseInstallation {
      installation.update(with: withParseInstallation)
    } else {
      installation.update()
    }// end if
    self.parseInstallation = installation
    self.parseUser = ParseUser(installationId: installationId)
    return installation
  }// end func recreateParseInstallation
  
  /// parse user instance
  var parseUser: ParseUser {
    /// local parse user  getter
    get {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      
      if let parseUser = self._parseUser {
        return parseUser
      } else {
        var user: ParseUser
        // installation id from parse installation
        if let installationId = self.parseInstallation.installationId {
          user = ParseUser(installationId: installationId)
        } else {
          user = ParseUser(installationId: recreateParseInstallation().installationId!)
        }// end if
        return user
      }// end if
    }// end get
    /// local parse user setter
    set {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      self._parseUser = newValue
      // persist session token
      if let sessionToken = newValue.sessionToken {
        persist(sessionToken: sessionToken)
      }// end if
    }// end set
  }// end var parseInstallation
  
  /// add `token` to `networkService` and `userDefaults`
  /// - parameter token: parse session token `String`
  func persist(sessionToken token: String) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.networkService.addSessionTokenHeader(sessionToken: token)
    self.userDefaults.parseSessionToken = token
  }// end func persist session
}// end extension class Launch
