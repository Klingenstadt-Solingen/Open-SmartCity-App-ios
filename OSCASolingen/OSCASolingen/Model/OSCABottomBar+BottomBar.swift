//
//  OSCABottomBar+BottomBar.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.08.22.
//

import Foundation
import OSCAEssentials

extension OSCABottomBar {
  public struct BottomBar {
    /// Auto generated id
    public private(set) var objectId: String?
    /// UTC date when the object was created
    public private(set) var createdAt: Date?
    /// UTC date when the object was changed
    public private(set) var updatedAt: Date?
    /// is tab bar item enabled
    var enabled: Bool? = false
    /// tab bar item's icon name
    var iconName: String?
    /// tab bar item's icon path
    var iconPath: String?
    /// tab bar item's icon mime type
    var iconMimeType: String?
    /// tab bar item's position
    var position: Int?
    /// is tab bar item  visible
    var visible: Bool?
    /// app's minimum version for tab bar item
    var minVersionApple: String?
    /// tab bar item's localized title key
    var localizedTitleId: String?
    /// list of deep link prefixes for tab bar item
    var deeplinkPrefixes: [String?]?
  } // end public struct BottomBar
}// end extension OSCABottomBar

extension OSCABottomBar.BottomBar {
  static let stubbed: [OSCABottomBar.BottomBar] = []
}// end extension public struct BottomBar

extension OSCABottomBar.BottomBar: OSCAParseClassObject {}
extension OSCABottomBar.BottomBar: Hashable {}
extension OSCABottomBar.BottomBar: Equatable {}

extension OSCABottomBar.BottomBar {
  /// Parse class name
  public static var parseClassName : String { return "BottomBar" }
}// end extension OSCABottomBar
