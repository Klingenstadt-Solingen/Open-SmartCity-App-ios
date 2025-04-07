//
//  OSCASolingenDIContainer.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 29.08.22.
//

import Foundation

extension OSCASolingen {
  final class DIContainer {
    private let dependencies: OSCASolingen.Dependencies
    
    public init(dependencies: OSCASolingen.Dependencies) {
      self.dependencies = dependencies
    }// end public init
    
  }// end final class DIContainer
}// end extension public struct OSCASolingen
