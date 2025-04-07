//
//  TownhallCollectionViewCellViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 23.06.22.
//

import Combine
import UIKit

final class TownhallCollectionViewCellViewModel {
  let imageDataCache: NSCache<NSString, NSData>
  var listItem: TownhallMenu
  var title: String = ""
  var imageDataFromCache: Data? {
    guard let objectId = listItem.objectId else { return nil }
    let imageData = imageDataCache.object(forKey: NSString(string: objectId))
    return imageData as Data?
  }
  
  private let cellRow: Int
  private var oscaTownhallMenu: OSCATownhallMenu
  private var bindings = Set<AnyCancellable>()
  
  public init(imageCache: NSCache<NSString, NSData>,
              oscaTownhallMenu: OSCATownhallMenu,
              listItem: TownhallMenu,
              at row: Int) {
    self.listItem = listItem
    cellRow = row
    self.oscaTownhallMenu = oscaTownhallMenu
    self.imageDataCache = imageCache
    
    setupBindings()
  }
  
  // MARK: - OUTPUT
  
  @Published private(set) var imageData: Data? = nil
  
  // MARK: - Private
  
  private func setupBindings() {
    title = listItem.title ?? ""
  }
  
  private func fetchImage() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let objectId = listItem.objectId,
          let baseURL = URL(string: listItem.iconPath ?? ""),
          let fileName = listItem.iconName,
          let mimeType = listItem.iconMimetype
    else { return }
    
    oscaTownhallMenu.fetchImage(objectId: objectId, baseURL: baseURL, fileName: fileName, mimeType: mimeType)
      .sink { completion in
        switch completion {
        case .finished:
          print("\(Self.self): finished \(#function)")
          
        case .failure:
          print("\(Self.self): .sink: failure \(#function)")
        }
        
      } receiveValue: { result in
        switch result {
        case let .success(fetchedImage):
          guard let imageData = fetchedImage.imageData,
                let objectId = self.listItem.objectId
          else { return }
          
          self.imageDataCache.setObject(
            NSData(data: imageData),
            forKey: NSString(string: objectId))
          self.imageData = fetchedImage.imageData
          
        case .failure:
          print("\(Self.self): receivedValue: failure \(#function)")
        }
      }
      .store(in: &bindings)
  }
}

// MARK: - INPUT. View event methods

extension TownhallCollectionViewCellViewModel {
  func didSetViewModel() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if imageDataFromCache == nil {
      fetchImage()
    } else {
      imageData = imageData as Data?
    }
  }
}
