//
//  TownhallData.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.11.21.
//  Reviewed by Stephan Breidenbach on 13.06.2022
//
import Foundation
import OSCAEssentials
/**
 Parse-Class: "TownhallData"
 */
public struct TownhallData {
  /// Auto generated id
  public private(set) var objectId                        : String?
  /// UTC date when the object was created
  public private(set) var createdAt                       : Date?
  /// UTC date when the object was changed
  public private(set) var updatedAt                       : Date?
  
  private var _isEnabled      : Bool?
  public var isEnabled        : Bool {
    if let _isEnabled = _isEnabled {
      return _isEnabled
    } else {
      return false
    }// end if
  }// end public var isEnabled
  public var enabled          : Bool?         //
  public var segue            : String?       //
  public var position         : Int?          //
  private var _isEnabledAndroid : Bool?
  public var isEnabledAndroid : Bool   {
    if let _isEnabledAndroid = _isEnabledAndroid {
      return _isEnabledAndroid
    } else {
      return false
    }// end if
  } // end isEnabeldAndroid
  public var visible          : Bool?         //
  public var subtitle         : String?       //
  public var title            : String?       //
  public var link             : String?       //
  public var image            : String?       // question
  public var minVersionApple  : String?       // question
  
  public enum CodingKeys: String, CodingKey {
    case objectId
    case createdAt
    case updatedAt
    case _isEnabled       = "enabled"  //
    case segue                         //
    case position                      //
    case _isEnabledAndroid  = "enabledAndroid" //
    case visible                       //
    case subtitle                      //
    case title                         //
    case link                          //
    case image                         //
    case minVersionApple               //
  }// end public enum CodingKeys
  
}// end struct TownhallData

extension TownhallData: OSCAParseClassObject {}

extension TownhallData: Equatable {}

extension TownhallData {
  /// Parse class name
  public static var parseClassName : String { return "TownhallData" }
}// end extension TownhallData


