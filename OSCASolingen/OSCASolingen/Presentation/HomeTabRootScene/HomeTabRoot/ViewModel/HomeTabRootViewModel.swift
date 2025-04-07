//
//  HomeTabRootViewModel.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//

import Combine
import OSCAEssentials
import UIKit

final class HomeTabRootViewModel {
  private var actions: HomeTabRootViewModel.Actions?
  let oscaBottomBar: OSCABottomBar!
  private var bindings: Set<AnyCancellable> = []
  private var deeplinkURL: URL?
  
  /**
   list of `HomeTabItem`s
   */
  private var homeTabItems: [OSCABottomBar.HomeTabItem] = []
 
  private var colorConf: OSCAColorSettings
  @Published private(set) var state: HomeTabRootViewModel.State = .loading
  @Published private(set) var homeTabItemViewModels: [HomeTabItemViewModel] = []
  @Published private(set) var url: URL? {
    didSet {
      /// deeplink url consumed!!
      self.deeplinkURL = nil
    }// end didSet
  }// end
  
  // MARK: designated init
  
  init(oscaBottomBar: OSCABottomBar,
       actions: HomeTabRootViewModel.Actions) {
    self.actions = actions
    colorConf = OSCAColorSettings()
    self.oscaBottomBar = oscaBottomBar
  } // end init actions
  
  // MARK: - Private
  private func update() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.loadDefaultTabItems()
  } // end private func update
} // end final class HomeTabRootViewModel

// MARK: - View Model Actions
extension HomeTabRootViewModel {
  struct Actions {
    let initializeNavigationItems: ([HomeTabItemViewModel], /* view models */
                                    String /* MoreTitle */) -> Void
    let resetNavigationItems: () -> Void
    let handleDeeplink: (HomeTabItemViewModel,/* Item */
                     URL/* deeplink prefix*/) -> Void
  } // end public struct HomeTabRootViewModelActions
}// end extension final class HomeTabRootViewModel

// MARK: - View Model State
extension HomeTabRootViewModel {
  enum State {
    case loading
    case finishedLoading
    case error(HomeTabRootViewModel.Error)
  } // end enum HomeTabRootViewModelState
}// end extension final class HomeTabRootViewModel
extension HomeTabRootViewModel.State: Equatable {}

// MARK: - View Model Error
extension HomeTabRootViewModel {
  enum Error {
    case bottomBarItemsFetch
  }// end enum Error
}// end extension final class HomeTabRootViewModel
extension HomeTabRootViewModel.Error: Swift.Error {}
extension HomeTabRootViewModel.Error: Equatable {}

// MARK: - Data Access
extension HomeTabRootViewModel {
  private func loadDefaultTabItems() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    homeTabItems = self.oscaBottomBar.defaultHomeTabItems
    homeTabItemViewModels = homeTabItems.map{ HomeTabItemViewModel($0) }
    selectItem(with: deeplinkURL)
    state = .finishedLoading
  } // end private func loadDefaultTabItems
  
  func fetchHomeTabBarItems() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    state = .loading
    let bottomBarPublisher: OSCABottomBar.OSCABottomBarPublisher = self.oscaBottomBar
      .fetchAllBottomBarItems()
      .asyncMap { $0
        // visible items only
        .filter({ $0.visible == true })
        // sorted by position in ascending order
        .sorted(by: { $0.position ?? 99 < $1.position ?? 99 })
      }// end asyncMap
      .eraseToAnyPublisher()
    let homeTabViewModelPublisher: OSCABottomBar.OSCAHomeTabViewModelPublisher = bottomBarPublisher
      .asyncMap { $0.compactMap { HomeTabItemViewModel(OSCABottomBar.HomeTabItem(bottomBarItem: $0)) } }
      .eraseToAnyPublisher()
    
    homeTabViewModelPublisher
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          self.state = .error(.bottomBarItemsFetch)
          self.loadDefaultTabItems()
        }
      } receiveValue: { barItemViewModels in
        self.homeTabItemViewModels = barItemViewModels
        self.selectItem(with: self.deeplinkURL)
      }
      .store(in: &bindings)
  }// end func fetchHomeTabBarItems
}// end extension final class HomeTabRootViewModel

// MARK: - Input, view event methods
extension HomeTabRootViewModel {
  func viewWillAppear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    update()
  } // end func viewWillAppear
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // TODO: implementation
  } // end func viewDidLoad
  
  func viewWillDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewWillDisappear
  
  func updateAllItems() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// invoke view model action `initializeNavigationItem` with `homeTabItemViewModels`
    actions?.initializeNavigationItems(self.homeTabItemViewModels, /* view models */
                                       self.tabBarMoreTitle) /* more title */
  } // end func didUpdateAllItems
  
  func didSelectItem(_ homeTabItemViewModel: HomeTabItemViewModel) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func didSelectItem
} // end extension class HomeTabRootViewModel

// MARK: - OUTPUT colors
extension HomeTabRootViewModel {
  /// color hex of the tab bar's background
  var tabBarBackgroundColor: UInt32 {
    return colorConf.grayLight.toRGB()
  } // end var tabBarBackgroundColor
  
  /// color hex of the tab bar's selected item
  var tabBarItemSelectedColor: UInt32 {
    return colorConf.primaryColor.toRGB()
  } // end var tabBarItemSelectedColor
  
  /// color hex of the tab bar's item
  var tabBarItemColor: UInt32 {
    return colorConf.grayDark.toRGB()
  } // end var tabBarItemColor
} // end extension final class HomeTabRootViewModel

// MARK: - OUTPUT localized strings
extension HomeTabRootViewModel {
  /// localized string for tab bar item home
  var tabBarItemHomeTitle: String { return self.oscaBottomBar.tabBarItemHomeTitle }// end var tabBarItemHomeTitle
  
  /* Disabled module Corona
  /// localized string for tab bar item corona
  var tabBarItemCoronaTitle: String { return self.oscaBottomBar.tabBarItemCoronaTitle }// end var tabBarItemCoronaTitle
   */
  
  /// localized string for tab bar item townhall
  var tabBarItemTownhallTitle: String { return self.oscaBottomBar.tabBarItemTownhallTitle }// end var tabBarItemTownhallTitle
  
  /// localized string for tab bar item service
  var tabBarItemServiceTitle: String { return self.oscaBottomBar.tabBarItemServiceTitle }// end var tabBarItemServiceTitle
  
  /// localized string for tab bar item press releases
  var tabBarItemPressTitle: String { return self.oscaBottomBar.tabBarItemPressTitle }// end var tabBarItemPressTitle
  
  /// localized string for tab bar item settings
  var tabBarItemSettingsTitle: String { return self.oscaBottomBar.tabBarItemSettingsTitle }// end var tabBarItemSettingsTitle
  
  /// localized string for tab bar more title
  var tabBarMoreTitle: String { return NSLocalizedString(
    "tabbar_more_title",
    bundle: OSCASolingen.bundle,
    comment: "The root tab bar more title")
  }// end var tabBarMoreTitle
  
  /// localized string for the alert title for an error
  var alertTitleError: String { return NSLocalizedString(
    "error_alert_title_error",
    bundle: OSCASolingen.bundle,
    comment: "The alert title for an error")
  }// end var alertTitleError
  
  /// localized string for the alert action title to confirm
  var alertActionConfirm: String { return NSLocalizedString(
    "error_alert_title_confirm",
    bundle: OSCASolingen.bundle,
    comment: "The alert action title to confirm")
  }// end var alertActionConfirm
}// end extension final class HomeTabRootViewModel

// MARK: - Deeplinking
extension HomeTabRootViewModel {
  func didReceiveDeeplink(with url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard !url.absoluteString.isEmpty else { return }
    self.deeplinkURL = url
    selectItem(with: url)
  }// end func didReceiveDeeplinkDetail
  
  private func selectItem(with url: URL?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let url = url,
          self.homeTabItemViewModels.contains(where: { $0.deeplinkPrefixes.contains(where: { url.absoluteString.hasPrefix($0) }) })
    else { return }
    self.url = url
  }// end private func selectItem with object id
  
  func show(tabBarItem: HomeTabItemViewModel, with url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    actions?.handleDeeplink(tabBarItem, url)
  }// end func show
}// end extension final class HomeTabRootViewModel
