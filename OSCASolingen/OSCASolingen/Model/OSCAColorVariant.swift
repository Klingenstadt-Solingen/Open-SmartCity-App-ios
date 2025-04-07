//
//  OSCAColorVariant.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 08.03.22.
//

import Foundation
import OSCAEssentials

public struct OSCAColorVariant {
  var title:       String
  var description: String
  var map        : [OSCAColorVariants: OSCAColorData]
}// end struct OSCAColorVariant

// -MARK: Equatable conformance
extension OSCAColorVariant: Equatable {
  public static func == (lhs: OSCAColorVariant, rhs: OSCAColorVariant) -> Bool {
    let equalsTitle       = lhs.title == rhs.title
    let equalsDescription = lhs.description == rhs .description
    var equalsMap: Bool {
      for variant in OSCAColorVariants.allCases {
        guard lhs.map[variant] == rhs.map[variant] else {
          return false
        }
      }// end for in
      return true
    }// end
    return equalsTitle &&
    equalsDescription &&
    equalsMap
  }// end static func ==
}// end extension public struct OSCAColorVariant

extension OSCAColorVariant {
  public init(_ from: OSCAColorSettings,
              colorKey: OSCAColorSettings.Keys,
              title : String,
              description: String
  ) {
    var map: [OSCAColorVariants : OSCAColorData] = [:]
    for variant in OSCAColorVariants.allCases {
      map[variant] = OSCAColorData(
        title: "\(colorKey.rawValue) \(variant.rawValue)",
        colorString: from.getBaseColor(for: colorKey).getColor(variant).toHexString(),
        colorHex: from.getBaseColor(for: colorKey).getColor(variant).toRGB()
      )// end map
    }// end for variant
    self.init(title: title,
              description: description,
              map: map)
  }// end public init from color settings key
}// end extension public struct OSCAColorVariant
