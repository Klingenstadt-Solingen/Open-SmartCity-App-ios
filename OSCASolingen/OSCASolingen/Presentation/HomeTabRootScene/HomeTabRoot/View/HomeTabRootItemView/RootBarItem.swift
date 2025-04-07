//
//  RootBarItem.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//

import UIKit

final class RootBarItem: UITabBarItem {
  var viewModel: HomeTabItemViewModel!
  public var id: String!
  
  
  static func fill(with viewModel: HomeTabItemViewModel) -> RootBarItem {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let item: Self = Self.init()
    item.viewModel = viewModel
    item.id = viewModel.id
    item.tag = item.viewModel.position
    item.title = item.viewModel.title
    let bundle = OSCASolingen.bundle
    item.image = UIImage(named: item.viewModel.icon,
                         in: bundle,
                         compatibleWith: nil)
    return item
  }// end func fill
}// end final class RootBarItem
