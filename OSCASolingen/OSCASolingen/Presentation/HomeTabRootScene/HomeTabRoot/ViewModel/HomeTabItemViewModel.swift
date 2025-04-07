//
//  HomeTabItemViewModel.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//  Reviewed by Stephan Breidenbach on 18.09.22.
//

import Foundation

public struct HomeTabItemViewModel: Equatable {
  public let id       : String        // id
  public let position : Int           // position in HomeTabRootBar
  public let icon     : String        // icon image name
  public let title    : String        // HomeTabItem title
  public let deeplinkPrefixes: [String]// deeplink prefixes for home tab item
}// end public struct HomeTabItemViewModel

extension HomeTabItemViewModel {
  public init(_ homeTabItem: OSCABottomBar.HomeTabItem) {
    self.id        = homeTabItem.id
    self.position  = Int(exactly: homeTabItem.position) ?? 0
    self.icon      = homeTabItem.icon
    self.title     = homeTabItem.title
    self.deeplinkPrefixes = homeTabItem.deeplinkPrefixes
  }// end public init
}// end extension struct HomeTabItemViewModel

extension HomeTabItemViewModel: Codable {}
extension HomeTabItemViewModel: Hashable {}
