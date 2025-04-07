//
//  ServiceListViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 23.06.22.
//

import Combine
import Foundation

struct ServiceListViewModelActions {
  /// navigate to service menu action closure
  let navigateTo: (ServiceMenu/*, Data?*/) -> Void
  let navigateToWithURL: (ServiceMenu,URL) -> Void
}// end struct 

public enum ServiceListViewModelError: Error, Equatable {
  case menuItemsFetch
}

public enum ServiceListViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(ServiceListViewModelError)
}

final class ServiceListViewModel {
  private let actions: ServiceListViewModelActions?
  let oscaServiceMenu: OSCAServiceMenu!
  private var bindings: Set<AnyCancellable> = []
  let deeplinkPrefixes: [String]
  var deeplinkURL: URL?
  var selectedItemId: String?
  
  let screenTitle = "Services"
  let imageDataCache = NSCache<NSString, NSData>()
  
  @Published private(set) var items: [ServiceMenu] = []
  @Published private(set) var state: ServiceListViewModelState = .loading
  @Published private(set) var selectedItem: Int? {
    didSet {
      /// selected item id consumed!!
      self.selectedItemId = nil
    }// end didSet
  }// end selected item
  
  enum Section { case serviceMenuItems }
  
  let alertTitleError: String = NSLocalizedString(
    "error_alert_title_error",
    bundle: OSCASolingen.bundle,
    comment: "The alert title for an error")
  let alertActionConfirm: String = NSLocalizedString(
    "error_alert_title_confirm",
    bundle: OSCASolingen.bundle,
    comment: "The alert action title to confirm")
  
  // MARK: Initializer
  
  init(oscaServiceMenu: OSCAServiceMenu,
       actions: ServiceListViewModelActions,
       deeplinkPrefixes: [String]) {
#if DEBUG
    print("\(Self.self): \(#function)")
#endif
    self.oscaServiceMenu = oscaServiceMenu
    self.actions = actions
    self.deeplinkPrefixes = deeplinkPrefixes
  } // end init
}

// MARK: - data access

extension ServiceListViewModel {
  func fetchServiceMenuItems() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    state = .loading
    oscaServiceMenu.fetchAllServiceMenu()
      .map {
        $0.filter({ $0.enabled == true })
      }
      .map {
        $0.sorted(by: { $0.position ?? 99 < $1.position ?? 99 })
      }
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.menuItemsFetch)
        }
      } receiveValue: { menuItems in
        self.items = menuItems
        self.selectItem(with: self.deeplinkURL)
      }
      .store(in: &bindings)
  } // end func
}

// MARK: - View Model Input

extension ServiceListViewModel {
  /// Module Navigation view lifecycle method
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    fetchServiceMenuItems()
  } // end func viewDidLoad
  
  /// Module Navigation view lifecycle method
  func viewWillAppear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewWillAppear
  
  /// Module Navigation view lifecycle method
  func viewWillDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewWillDisappear
  
  /// Module Navigation view lifecycle method
  func viewDidDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewDidDisappear
}

extension ServiceListViewModel {
  /// pull to refresh event
  func callPullToRefresh() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    fetchServiceMenuItems()
  }// end func callPullToRefresh
  
  func didSelectItem(at index: Int) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard index < items.count else { return }
    if let url = self.deeplinkURL {
      actions?.navigateToWithURL(items[index], url)
      /// deep link url consumed
      deeplinkURL = nil
    } else {
      //    let imageData = imageDataCache.object(forKey: NSString(string: objectId)) as Data?
      self.actions?.navigateTo(items[index]/*, imageData*/)
    }// end if
  }// end func didSelectItem at index
}// end extension ServiceListViewModel

// MARK: - Deeplinking
extension ServiceListViewModel {
  func didReceiveDeeplink(with url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard !url.absoluteString.isEmpty else { return }
    self.deeplinkURL = url
    selectItem(with: url)
  }// end func didReceiveDeeplink with url
  
  private func selectItem(with url: URL?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let url = url,
          let prefix = self.deeplinkPrefixes.first(where: {url.absoluteString.hasPrefix($0) }),
          let deeplinkScheme = url.scheme
    else { return }
    switch prefix {
    case "\(deeplinkScheme)://service":
      /// deeplink url consumed
      self.deeplinkURL = nil
      return
    case "\(deeplinkScheme)://jobs":
      guard let item = self.items.first(where: { $0.seque == ServiceMenu.Seque.jobs }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://transport":
      guard let item = self.items.first(where: { $0.seque == ServiceMenu.Seque.publicTransport }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://coworking":
      guard let item = self.items.first(where: { $0.seque == ServiceMenu.Seque.coworking }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://mobilitymonitor":
      guard let item = self.items.first(where: { $0.seque == ServiceMenu.Seque.mobilityMonitor }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://art":
      guard let item = self.items.first(where: { $0.seque == ServiceMenu.Seque.art }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    default:
      deeplinkURL = nil
      return
    }// end switch case
    return
  }// end select item with url
  
  private func didReceiveDeeplinkDetail(with objectId: String) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard !objectId.isEmpty else { return }
    self.selectedItemId = objectId
    selectItem(with: objectId)
  }// end func didReceiveDeeplinkDetail
  
  private func selectItem(with objectId: String?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let objectId = objectId,
          let index = self.items.firstIndex(where: { $0.objectId == objectId})
    else { return }
    self.selectedItem = index
  }// end private func selectItem with object id
}// end extension final class ServiceListViewModel
