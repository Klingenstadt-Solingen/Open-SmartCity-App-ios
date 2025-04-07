//
//  TownhallMenu.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 21.06.22.
//

import Foundation
import OSCAEssentials

public struct TownhallMenu {
  public enum Seque: String {
    case contact
    case waste
    case defect
    case http
    case school
    case appointment = "TableMenu-termin"
  } // end public enum Seque
  
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
  var seque: TownhallMenu.Seque?
  var position: Int?
  var visible: Bool?
  var minVersionApple: String?
  var title: String?
  var link: String?
  var appleDeeplink: String?
} // end public struct TownhallMenu

extension TownhallMenu.Seque: Codable {}

extension TownhallMenu.Seque: Equatable {}

extension TownhallMenu: OSCAParseClassObject {}

extension TownhallMenu: Hashable {}

extension TownhallMenu: Equatable {}

extension TownhallMenu {
  /// Parse class name
  public static var parseClassName : String { return "TownhallMenu" }
}// end extension TownhallMenu
