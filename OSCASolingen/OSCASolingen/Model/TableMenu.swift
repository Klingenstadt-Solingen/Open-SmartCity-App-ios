//
//  TableMenu.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 22.11.22.
//

import OSCAEssentials
import Foundation

public struct TableMenu: Equatable {
  /// Auto generated id
  public private(set) var objectId: String?
  /// UTC date when the object was created
  public private(set) var createdAt: Date?
  /// UTC date when the object was changed
  public private(set) var updatedAt: Date?
  
  public var enabled: Bool?
  public var visible: Bool?
  public var title: String?
  public var subtitle: String?
  public var url: String?
  public var seque: TableMenu.Segue?
  public var position: Int?
  public var ref: String?
  public var iconName: String?
  public var iconPath: String?
  public var iconMimetype: String?
  
  public enum Segue: String, Codable, Equatable, Hashable {
    case http = "http"
  }
  
  public enum MimeType: String, Codable, Equatable, Hashable {
    case png   = ".png"
    case jpg   = ".jpg"
    case jpeg  = ".jpeg"
    case empty = ""
  }
}

extension TableMenu: OSCAParseClassObject {
  public static var parseClassName: String { "TableMenu" }
}
