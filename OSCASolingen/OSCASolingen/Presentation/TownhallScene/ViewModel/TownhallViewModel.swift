//
//  TownhallViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 21.06.22.
//  Reviewed by Stephan Breidenbach on 16.02.23
//

import Combine
import Foundation

struct TownhallViewModelActions {
  let navigateTo: (TownhallMenu /* , Data? */ ) -> Void
  let navigateToWithURL: (TownhallMenu,URL) -> Void
}// end struct TownhallViewModelActions

public enum TownhallViewModelError: Error, Equatable {
  case townhallMenuItemsFetch
}// end public enum TownhallViewModelError

public enum TownhallViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(TownhallViewModelError)
}// end public enum TownhallViewModelState

final class TownhallViewModel {
  private let actions: TownhallViewModelActions?
  let oscaTownhallMenu: OSCATownhallMenu!
  private var bindings: Set<AnyCancellable> = []
  let deeplinkPrefixes: [String]
  var deeplinkURL: URL?
  var selectedItemId: String?
  
  let screenTitle = "Digitales Rathaus"
  
  let imageDataCache = NSCache<NSString, NSData>()
  
  @Published private(set) var items: [TownhallMenu] = []
  @Published private(set) var state: TownhallViewModelState = .loading
  @Published private(set) var selectedItem: Int? {
    didSet {
      /// selected item id consumed!!
      self.selectedItemId = nil
    }// end didSet
  }// end selected item
  
  enum Section { case townhallMenuItems }
  
  let alertTitleError: String = NSLocalizedString(
    "error_alert_title_error",
    bundle: OSCASolingen.bundle,
    comment: "The alert title for an error")
  let alertActionConfirm: String = NSLocalizedString(
    "error_alert_title_confirm",
    bundle: OSCASolingen.bundle,
    comment: "The alert action title to confirm")
  
  /// inject view model actions
  init(oscaTownhallMenu: OSCATownhallMenu,
       actions: TownhallViewModelActions,
       deeplinkPrefixes: [String]) {
#if DEBUG
    print("\(Self.self): \(#function)")
#endif
    self.oscaTownhallMenu = oscaTownhallMenu
    self.actions = actions
    self.deeplinkPrefixes = deeplinkPrefixes
  } // end init
}// end final class TownhallViewModel

// MARK: - data access

extension TownhallViewModel {
  func fetchTownhallMenuItems() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    state = .loading
    oscaTownhallMenu.fetchAllTownhallMenu()
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
          self.state = .error(.townhallMenuItemsFetch)
        }
      } receiveValue: { menuItems in
        self.items = menuItems
        self.selectItem(with: self.deeplinkURL)
      }
      .store(in: &bindings)
  } // end func
}// end extension final class TownhallViewModel

// MARK: - View Model Input

extension TownhallViewModel {
  /// ViewController lifecycle method
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    fetchTownhallMenuItems()
  } // end func viewDidLoad
  
  /// ViewController  lifecycle method
  func viewWillAppear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewWillAppear
  
  /// ViewController lifecycle method
  func viewWillDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewWillDisappear
  
  /// ViewController lifecycle method
  func viewDidDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewDidDisappear
}// end extension final class TownhallViewModel

extension TownhallViewModel {
  /// item selection event in `UICollectionView
  func didSelectItem(at index: Int) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard index < items.count else { return }
    if let url = self.deeplinkURL {
      actions?.navigateToWithURL(items[index], url)
      /// deeplink url consumed
      self.deeplinkURL = nil
    } else {
      //    let imageData = imageDataCache.object(forKey: NSString(string: objectId)) as Data?
      actions?.navigateTo(items[index] /* , imageData */ )
    }// end if
  }// end func didSelectItem
  
  /// pull to refresh event
  func callPullToRefresh() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    fetchTownhallMenuItems()
  }// end func callPullToRefresh
}// end extension final class TownhallViewModel

// MARK: - Deeplinking
extension TownhallViewModel {
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
    case "\(deeplinkScheme)://townhall":
      /// deeplink url consumed
      self.deeplinkURL = nil
      return
    case "\(deeplinkScheme)://contact":
      guard let item = self.items.first(where: { $0.seque == TownhallMenu.Seque.contact }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://defect":
      guard let item = self.items.first(where: { $0.seque == TownhallMenu.Seque.defect }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://waste":
      guard let item = self.items.first(where: { $0.seque == TownhallMenu.Seque.waste }),
            let objectId = item.objectId
      else { return }
      didReceiveDeeplinkDetail(with: objectId)
    case "\(deeplinkScheme)://appointments":
      guard let item = self.items.first(where: { $0.seque == TownhallMenu.Seque.appointment }),
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
}// end extension final class TownhallViewModel
