//
//  ParseInstallation+Push.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 02.02.24.
//

import Foundation
import OSCAEssentials
import OSCANetworkService
import Combine

extension ParseInstallation {
  typealias InstallationPublisher = AnyPublisher<ParseInstallation, OSCANetworkError>
  mutating func processDeviceToken(_ token: Data) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let deviceToken = token.map { String(format: "%02.2hhx", $0) }.joined()
#if DEBUG
    print(#function)
    print("Device Token: \(deviceToken)")
#endif
    self.deviceToken = deviceToken
  }// end private func processDeviceToken
  
  mutating func subscribe(to key: Launch.Keys) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if channels == nil {
      channels = []
    }// end if
    if let _ = channels?.first(where: { $0 == key.rawValue }) {
      return
    } else {
      channels?.append(key.rawValue)
    }// end if
  }// end mutating func subscribe to key
  
  mutating func unsubscribe(from key: Launch.Keys) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if channels == nil {
      channels = []
    }// end if
    channels?.removeAll(where: { $0 == key.rawValue })
  }// end mutating func unsubscribe from key
}// end extension ParseInstallation
