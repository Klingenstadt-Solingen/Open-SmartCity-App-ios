//
//  ParseInstallation+Update.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.02.24.
//

import Foundation
import OSCAEssentials
import DeviceKit

extension ParseInstallation {
  mutating func update(with installation: ParseInstallation) {
    if let objectId = installation.objectId {
      self.objectId = objectId
    }
    if let createdAt = installation.createdAt {
      self.createdAt = createdAt
    }
    if let updatedAt = installation.updatedAt {
      self.updatedAt = updatedAt
    }// end if
    if let channels = installation.channels {
      self.channels = channels
    }// end if
    if let deviceToken = installation.deviceToken {
      self.deviceToken = deviceToken
    }// end if
  }// end mutating function update with installation
  
  mutating func update() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var appVersion: String?
    let bundle = Bundle.main
    if bundle.bundleIdentifier != nil {
      appVersion = bundle.infoDictionary!["CFBundleVersion"] as? String
    } else
    if let bundle = OSCASolingen.bundle {
      appVersion = bundle.infoDictionary!["CFBundleVersion"] as? String
    }
    self.appIdentifier = Bundle.main.bundleIdentifier
    self.appName = "Solingen App"
    self.appVersion = appVersion ?? ""
    self.deviceModel = Device.current.description
    self.localeIdentifier = Locale.current.identifier
    self.osType = Device.current.systemName
    self.osVersion = Device.current.systemVersion
    self.timeZone = TimeZone.current.identifier
  }// end mutating func update
}// end extension struct ParseInstallation
