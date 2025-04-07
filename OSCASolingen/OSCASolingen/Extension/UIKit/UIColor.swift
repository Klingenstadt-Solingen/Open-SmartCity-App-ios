//
//  UIColor.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import UIKit

/// An object that stores color data and sometimes opacity.
public extension UIColor {
  static var primary: UIColor {
    UIColor(named: "Primary",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0x005AAA)
  }
  
  static var accent: UIColor {
    UIColor(named: "Accent",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0xFFD503)
  }
  
  static var success: UIColor {
    UIColor(named: "Success",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0x3CC13B)
  }
  
  static var warning: UIColor {
    UIColor(named: "Warning",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0xF3BB1C)
  }
  
  static var error: UIColor {
    UIColor(named: "Error",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0xF03738)
  }
  
  static var gray: UIColor {
    UIColor(named: "Gray",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0xC2C9D1)
  }
  
  static var black: UIColor {
    UIColor(named: "Black",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0x000000)
  }
  
  static var white: UIColor {
    UIColor(named: "White",
            in: OSCASolingen.bundle,
            compatibleWith: nil)
    ?? UIColor(rgb: 0xFFFFFF)
  }
}
