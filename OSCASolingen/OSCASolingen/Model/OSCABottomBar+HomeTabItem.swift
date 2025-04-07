//
//  OSCABottomBar+HomeTabItem.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//

import Foundation
import OSCAEssentials

extension OSCABottomBar {
  public struct HomeTabItem {
    public let id       : String       // id
    public let position : UInt8        // position in HomeTabRootBar
    public let icon     : String       // icon image name
    public let title    : String       // HomeTabItem title
    public let deeplinkPrefixes: [String] // deeplink prefixes for home tab item
  }// end public struct HomeTabItem
}// end extension public struct OSCABottomBar

extension OSCABottomBar.HomeTabItem {
  public init(bottomBarItem: OSCABottomBar.BottomBar) {
    self.id = bottomBarItem.localizedTitleId ?? ""
    self.position = UInt8(bottomBarItem.position ?? 99)
    self.icon = bottomBarItem.iconName ?? ""
    if let localizedTitleId = bottomBarItem.localizedTitleId,
       let itemTitle = OSCABottomBar.localizedTabBarItemTitles[localizedTitleId] {
      self.title = itemTitle
    } else {
      self.title = ""
    }// end if
    self.deeplinkPrefixes = bottomBarItem.deeplinkPrefixes?.compactMap{$0} ?? []
  }// end public init from bottom bar item
}// end extension OSCABottomBar.HomeTabItem

// MARK: - Tab Bar Item title
extension OSCABottomBar {
  static var localizedTabBarItemTitles: [String:String] {
    let tabBarItemHomeTitle = NSLocalizedString(
      "tabbaritem_home_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item home title")
    /* Disabled module Corona
    let tabBarItemCoronaTitle = NSLocalizedString(
      "tabbaritem_corona_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item corona title")
     */
    let tabBarItemTownhallTitle = NSLocalizedString(
      "tabbaritem_townhall_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item townhall title")
    let tabBarItemServiceTitle = NSLocalizedString(
      "tabbaritem_service_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item service title")
    let tabBarItemPressTitle = NSLocalizedString(
      "tabbaritem_press_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item press title")
    let tabBarItemSettingsTitle = NSLocalizedString(
      "tabbaritem_settings_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item settings title")
    
    return ["tabBarItemHomeTitle": tabBarItemHomeTitle,
    /* Disabled module Corona
            "tabBarItemCoronaTitle": tabBarItemCoronaTitle,
     */
            "tabBarItemTownhallTitle": tabBarItemTownhallTitle,
            "tabBarItemServiceTitle": tabBarItemServiceTitle,
            "tabBarItemPressTitle": tabBarItemPressTitle,
            "tabBarItemSettingsTitle": tabBarItemSettingsTitle]
  }// end var localizedTabBarItemTitles
  
  var tabBarItemHomeTitle: String { return
    NSLocalizedString(
      "tabbaritem_home_title",
      bundle: OSCASolingen.bundle,
      comment: "root tab bar item home title")
  }// end var tabBarItemHomeTitle
  
  /* Disabled module Corona
  var tabBarItemCoronaTitle: String { return NSLocalizedString(
    "tabbaritem_corona_title",
    bundle: OSCASolingen.bundle,
    comment: "root tab bar item corona title") }
   */
  
  var tabBarItemTownhallTitle: String { return NSLocalizedString(
    "tabbaritem_townhall_title",
    bundle: OSCASolingen.bundle,
    comment: "root tab bar item townhall title") }
  
  var tabBarItemServiceTitle: String { return NSLocalizedString(
    "tabbaritem_service_title",
    bundle: OSCASolingen.bundle,
    comment: "root tab bar item service title") }
  
  var tabBarItemPressTitle: String { return NSLocalizedString(
    "tabbaritem_press_title",
    bundle: OSCASolingen.bundle,
    comment: "root tab bar item press title") }
  
  var tabBarItemSettingsTitle: String { return NSLocalizedString(
    "tabbaritem_settings_title",
    bundle: OSCASolingen.bundle,
    comment: "root tab bar item settings title") }
}// end extension public struct OSCABottomBar

// MARK: - default Tab Bar
extension OSCABottomBar {
  var defaultHomeTabItems: [OSCABottomBar.HomeTabItem] {
    let deeplinkScheme: String = deeplinkScheme
    let home = "\(deeplinkScheme)://home"
    let townhall = "\(deeplinkScheme)://townhall"
    let service = "\(deeplinkScheme)://service"
    let settings = "\(deeplinkScheme)://settings"
    let pressReleases = "\(deeplinkScheme)://pressreleases"
    let contact = "\(deeplinkScheme)://contact"
    let defect = "\(deeplinkScheme)://defect"
    /* Disabled module Corona
    let corona = "\(deeplinkScheme)://corona"
     */
    let jobs = "\(deeplinkScheme)://jobs"
    let poi = "\(deeplinkScheme)://poi"
    let transport = "\(deeplinkScheme)://transport"
    let waste = "\(deeplinkScheme)://waste"
    let sensorstation = "\(deeplinkScheme)://sensorstation"
    let events = "\(deeplinkScheme)://events"
    let coworking = "\(deeplinkScheme)://coworking"
    let art = "\(deeplinkScheme)://art"
    let mobility = "\(deeplinkScheme)://mobilitymonitor"
    let appointments = "\(deeplinkScheme)://appointments"
    let district = "\(deeplinkScheme)://district"
    return [
      OSCABottomBar.HomeTabItem(id: "tabbaritem_home_title",
                                position: 0,
                                icon: "city-svg",
                                title: tabBarItemHomeTitle,
                                deeplinkPrefixes: [home,
                                                   poi,
                                                   sensorstation,
                                                   events,
                                                   district]),
    /* Disabled module Corona
      OSCABottomBar.HomeTabItem(id: "tabbaritem_corona_title",
                                position: 1,
                                icon: "corona-svg",
                                title: tabBarItemCoronaTitle,
                                deeplinkPrefixes: [corona]),
     */
      OSCABottomBar.HomeTabItem(id: "tabbaritem_townhall_title",
                                position: 1,
                                icon: "cityhall-svg",
                                title: tabBarItemTownhallTitle,
                                deeplinkPrefixes: [townhall,
                                                   contact,
                                                   defect,
                                                   waste,
                                                   appointments]),
      OSCABottomBar.HomeTabItem(id: "tabbaritem_service_title",
                                position: 2,
                                icon: "services-svg",
                                title: tabBarItemServiceTitle,
                                deeplinkPrefixes: [service,
                                                   jobs,
                                                   transport,
                                                   coworking,
                                                   art,
                                                   mobility]),
      OSCABottomBar.HomeTabItem(id: "tabbaritem_press_title",
                                position: 3,
                                icon: "press-release-svg",
                                title: tabBarItemPressTitle,
                                deeplinkPrefixes: [pressReleases]),
      OSCABottomBar.HomeTabItem(id: "tabbaritem_settings_title",
                                position: 4,
                                icon: "cog-solid-svg",
                                title: tabBarItemSettingsTitle,
                                deeplinkPrefixes: [settings]),
    ]
  }// end var defaultHomeTabItems
}// end extension public struct OSCABottomBar
