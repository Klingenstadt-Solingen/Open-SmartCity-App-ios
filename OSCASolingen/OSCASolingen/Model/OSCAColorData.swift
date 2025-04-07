//
//  OSCAColorData.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 08.03.22.
//

import Foundation
import OSCAEssentials

public struct OSCAColorData {
  var title:       String
  var colorString: String
  var colorHex:    UInt32
}// end public struct OSCAColorData

extension OSCAColorData: Equatable {}
