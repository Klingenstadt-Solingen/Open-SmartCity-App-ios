//
//  OSCAColorSettingsKeys+index.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 11.03.22.
//
import Foundation
import OSCAEssentials

public extension OSCAColorSettings.Keys {
  static var count: Int { return Self.allCases.count }
  var index: Int {
    return [
      .primary,
      .accent,
      .success,
      .warning,
      .error,
      .gray,
      .black,
      .white
    ].firstIndex(of: self) ?? Self.allCases.firstIndex(of: self) ?? 0
  }// end var index
  static func findKey(by index: Int) -> Self? {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return Self.allCases.first(where: { $0.index == index })
  }// end func findKey
}// end public extension enum OSCAColorSettings.Keys
