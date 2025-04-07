//
//  ParseUser.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 07.10.22.
//  reviewed by Stephan Breidenbach on 24.10.22
//  reviewed by Stephan Breidenbach on 01.02.24
//

import Foundation
import OSCAEssentials
import OSCANetworkService
import Combine

public extension ParseUser {
  var installationId: String? {
    return self.authData?.anonymous.id
  }// end var installtionId
  
  /// use this `ParseUser` to login anonymous to Parse backend asynchronously
  func loginAnonymously(networkService: OSCANetworkService) -> AnyPublisher<ParseUser, OSCANetworkError> {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let fail = Fail(outputType: ParseUser.self,
                    failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    
    guard let installationId = self.installationId else { return fail }
    
    let loginRequest = OSCALoginRequestResource(baseURL: networkService.config.baseURL,
                                                parseInstallationId: installationId,
                                                authDataObject: ParseAuthData(uuid: installationId),
                                                headers: networkService.config.headers)
    
    return networkService.login(loginRequest)
  }// end func loginAnonymously
}// end public extension ParseUser

public extension ParseUser {
  init(installationId: String){
    self = ParseUser(authData: ParseAuthData.AuthData(anonymous: ParseAuthData.AuthData.ID(id: installationId)))
  }

  mutating func update(with user: ParseUser) {
    if let objectId = user.objectId {
      self.objectId = objectId
    }// end if
    if let updatedAt = user.updatedAt {
      self.updatedAt = updatedAt
    }// end if
    if let createdAt = user.createdAt {
      self.createdAt = createdAt
    }// end if
    if let username = user.username {
      self.username = username
    }// end if
    if let sessionToken = user.sessionToken {
      self.sessionToken = sessionToken
    }// end if
    if let authData = user.authData {
      self.authData = authData
    }// end if
    if let firstname = user.firstname {
      self.firstname = firstname
    }// end if
    if let lastname = user.lastname {
      self.lastname = lastname
    }// end if
  }// end mutating function update with installation
}// end public extension ParseUser

public extension ParseUser {
  /// UserDefaults object keys
  enum Keys: String {
    case userDefaultsParseUser = "OSCASolingen_ParseUserObject"
  }// end enum Keys
}// end public extension ParseUser
