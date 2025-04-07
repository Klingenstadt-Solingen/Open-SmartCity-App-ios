//
//  ServiceMenu.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 23.06.22.
//

import Foundation
import OSCAEssentials

public struct ServiceMenu {
  public enum Seque: String {
    case publicTransport = "publicTransport"
    case events          = "events"
    case coworking       = "coworking"
    case http            = "http"
    case jobs            = "jobs"
    case art             = "art"
    case mobilityMonitor = "mobilitymonitor"
    case investment = "investment"
  }// end public enum Seque
  /// Auto generated id
  public private(set) var objectId: String?
  /// UTC date when the object was created
  public private(set) var createdAt: Date?
  /// UTC date when the object was changed
  public private(set) var updatedAt: Date?
  var enabled: Bool? = false
  var iconName: String?
  var iconPath: String?
  var iconMimetype: String?
  var seque: ServiceMenu.Seque?
  var position: Int?
  var visible: Bool?
  var minVersionApple: String?
  var title: String?
  var subtitle: String?
  var link: String?
  var appleDeeplink: String?
} // end public struct ServiceMenu

extension ServiceMenu.Seque: Codable {}

extension ServiceMenu.Seque: Equatable {}

extension ServiceMenu.Seque: Hashable {}

extension ServiceMenu {
  static let stubbed: [ServiceMenu] = []
}

extension ServiceMenu: OSCAParseClassObject {}

extension ServiceMenu: Hashable {}

extension ServiceMenu: Equatable {}

extension ServiceMenu {
  /// Parse class name
  public static var parseClassName : String { return "ServiceMenu" }
}// end extension ServiceMenu
