//
//  CityCollectionHeaderViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 17.06.22.
//

import Foundation
import OSCAEssentials

struct CityCollectionHeaderViewModelActions {
  let moreButtonTouch: (Int) -> Void
}

final class CityCollectionHeaderViewModel {
  var title: String
  var section: Int
  var buttonTitle: String
  let colorSettings: OSCAColorSettings = OSCAColorSettings()
  private let actions: CityCollectionHeaderViewModelActions?
  
  // - MARK: view model init
  /// inject view model actions
  init(title: String = "", section: Int, buttonTitle: String = "", actions: CityCollectionHeaderViewModelActions) {
    self.title = title
    self.buttonTitle = buttonTitle
    self.section = section
    self.actions = actions
  } // end init
  
  func moreButtonTouched(tag: Int) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    actions?.moreButtonTouch(tag)
  }
} // end final class
