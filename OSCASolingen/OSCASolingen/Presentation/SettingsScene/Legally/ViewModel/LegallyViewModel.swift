//
//  LegallyViewModel.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 06.10.22.
//

import Foundation

struct LegallyViewModelActions {}

final class LegallyViewModel {
  private let actions: LegallyViewModelActions?
  private let data   : Settings
  let screenTitle: String
  let text: String
  
  // MARK: Initializer
  init(actions    : LegallyViewModelActions,
       data       : Settings,
       screenTitle: String,
       text       : String) {
    self.actions     = actions
    self.data        = data
    self.screenTitle = screenTitle
    self.text        = text
  }
}

// MARK: - INPUT. View event methods
extension LegallyViewModel {
  func viewDidLoad() {}
}
