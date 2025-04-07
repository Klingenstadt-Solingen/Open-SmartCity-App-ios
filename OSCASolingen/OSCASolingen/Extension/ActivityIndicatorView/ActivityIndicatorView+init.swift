//
//  ActivityIndicatorView+init.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 07.02.24.
//

import UIKit
import OSCAEssentials

extension ActivityIndicatorView {
  /// initializes activity indicator view
  /// - parameter style:
  /// - parameter color: color of the activity indicator
  /// - parameter backgroundColor: background color of the activity indicator
  public convenience init(style: UIActivityIndicatorView.Style,
                          color: UIColor = .black,
                          backgroundColor: UIColor = .darkGray.withAlphaComponent(0.75)) {
    self.init(style: style)
    setup(color: color,
          backgroundColor: backgroundColor)
  }// end public convenience init
  
  private func setup(color: UIColor,
                     backgroundColor: UIColor) {
    self.color = .black
    self.backgroundColor = backgroundColor
    self.layer.cornerRadius = 5.0
    hidesWhenStopped = true
  }// end private func setup
}// end extension public final class ActivityIndicatorView
