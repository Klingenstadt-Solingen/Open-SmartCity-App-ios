//
//  PushNotification.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 24.01.23.
//

import Foundation
import OSCAEssentials
/**
 Parse-Class: "PushNotification"
 */
public struct PushNotification {
  /// Auto generated id
  public private(set) var objectId                        : String?
  /// UTC date when the object was created
  public private(set) var createdAt                       : Date?
  /// UTC date when the object was changed
  public private(set) var updatedAt                       : Date?
  
  public var variables: JSON?
  public var scheduledAt: ParseDate?
  public var additionalData: JSON?
  public var template: String?
  public var status: String?
  public var priority: Int?
  public var ref: String?
  public var stats: Stats?
  
  private enum CodingKeys: String, CodingKey {
    case objectId
    case createdAt
    case updatedAt
    case variables
    case scheduledAt
    case additionalData
    case template
    case status
    case priority
    case ref
    case stats
  }// end public enum CodingKeys
  
}// end struct PushNotification

extension PushNotification: OSCAParseClassObject {}

extension PushNotification: Equatable {}

extension PushNotification {
  /// Parse class name
  public static var parseClassName : String { return "PushNotification" }
}// end extension PushNotification

// MARK: - Stats
extension PushNotification {
  public struct Stats {
    public var ios: OS?
    public var android: OS?
  }// end public struct Stats
}// end extension PushNotification

extension PushNotification.Stats: Codable {}
extension PushNotification.Stats: Hashable {}
extension PushNotification.Stats: Equatable {}

// MARK: - OS
extension PushNotification.Stats {
  public struct OS {
    public var chunk: Chunk?
  }// end public struct IOS
}// end extension public struct PushNotification

extension PushNotification.Stats.OS: Codable {}
extension PushNotification.Stats.OS: Hashable {}
extension PushNotification.Stats.OS: Equatable {}

// MARK: - Chunk
extension PushNotification.Stats {
  public struct Chunk {
    public var total: Int?
  }// end public struct Chunk
}// end extension Stats

extension PushNotification.Stats.Chunk: Codable {}
extension PushNotification.Stats.Chunk: Hashable {}
extension PushNotification.Stats.Chunk: Equatable {}
