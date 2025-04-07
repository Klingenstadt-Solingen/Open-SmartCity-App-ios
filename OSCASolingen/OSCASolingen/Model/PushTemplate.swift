//
//  PushTemplate.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 24.01.23.
//

import Foundation
import OSCAEssentials
/**
 Parse-Class: "PushTemplate"
 */
public struct PushTemplate {
  /// Auto generated id
  public private(set) var objectId                        : String?
  /// UTC date when the object was created
  public private(set) var createdAt                       : Date?
  /// UTC date when the object was changed
  public private(set) var updatedAt                       : Date?
  
  public var channels: [String?]?
  public var templateId: String?
  public var description: String?
  public var title: String?
  public var body: String?
  public var category: String?
  
  private enum CodingKeys: String, CodingKey {
    case objectId
    case createdAt
    case updatedAt
    case channels
    case templateId
    case description
    case title
    case body
    case category
  }// end public enum CodingKeys
  
}// end struct PushTemplate

extension PushTemplate: OSCAParseClassObject {}

extension PushTemplate: Equatable {}

extension PushTemplate {
  /// Parse class name
  public static var parseClassName : String { return "PushTemplate" }
}// end extension PushTemplate
