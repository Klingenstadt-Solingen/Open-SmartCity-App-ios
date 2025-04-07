//
//  OSCAColorSettings+Map.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 10.03.22.
//

import OSCAEssentials
import Foundation
import UIKit

public extension OSCAColorSettings {
  func getBaseColor( for key: OSCAColorSettings.Keys ) -> UIColor {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    switch key {
    case .primary:
      return self.primaryColor
    case .accent:
      return self.accentColor
    case .success:
      return self.successColor
    case .warning:
      return self.warningColor
    case .error:
      return self.errorColor
    case .gray:
      return self.grayColor
    case .black:
      return self.blackColor
    case .white:
      return self.whiteColor
    }// end switch case
  }// end func getBaseColor for key
  
  var map: [OSCAColorSettings.Keys: OSCAColorVariant] {
    return [
      .primary   : OSCAColorVariant(
        self,
        colorKey: .primary,
        title: "Primary color variants",
        description: "This color should be displayed most frequently and be used for important actions"),
      .accent    : OSCAColorVariant(
        self,
        colorKey: .accent,
        title: "Accent color variants",
        description: "This color should be applied sparingly to highlight information or add personality"),
      .success   : OSCAColorVariant(
        self,
        colorKey: .success,
        title: "Success color variants",
        description: "This color should be used to show positive feedback or status."),
      .warning   : OSCAColorVariant(
        self,
        colorKey: .warning,
        title: "Warning color variants",
        description: "This color should be used to show warning feedback or status."),
      .error     : OSCAColorVariant(
        self,
        colorKey: .error,
        title: "Error color variants",
        description: "This color should be used to show negative feedback or status."),
      .gray      : OSCAColorVariant(
        self,
        colorKey: .gray,
        title: "Gray color variants",
        description: "This color should be used for backgrounds, icons, and division lines."),
      .black     : OSCAColorVariant(
        self,
        colorKey: .black,
        title: "Black color variants",
        description: "This color should be used for text."),
      .white     : OSCAColorVariant(
        self,
        colorKey: .white,
        title: "White color variants",
        description: "This color should be used for text.")
    ]// end return
  }// end var map
}// end public extension struct OSCAColorSettings
