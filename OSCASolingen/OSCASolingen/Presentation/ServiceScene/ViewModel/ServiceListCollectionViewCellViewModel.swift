//
//  ServiceListCollectionViewCellViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 23.06.22.
//

import Combine
import Foundation
import UIKit

final class ServiceListCollectionViewCellViewModel {
  let parentViewModel: ServiceListViewModel!
  var listItem: ServiceMenu
  var title: String = ""
  var subtitle: String = ""
  var imageDataFromCache: Data? {
    guard let objectId = listItem.objectId else { return nil }
    let imageData = parentViewModel.imageDataCache.object(forKey: NSString(string: objectId))
    return imageData as Data?
  }
  
  private let cellRow: Int
  private var oscaServiceMenu: OSCAServiceMenu
  private var bindings = Set<AnyCancellable>()
  
  public init(viewModel: ServiceListViewModel,
              listItem: ServiceMenu,
              at row: Int) {
    parentViewModel = viewModel
    self.listItem = listItem
    cellRow = row
    oscaServiceMenu = parentViewModel.oscaServiceMenu
    
    setupBindings()
  }
  
  // MARK: - OUTPUT
  
  @Published private(set) var imageData: Data? = nil
  
  // MARK: - Private
  
  private func setupBindings() {
    title = listItem.title ?? ""
    subtitle = listItem.subtitle ?? ""
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
    
    oscaServiceMenu.fetchImage(objectId: objectId, baseURL: baseURL, fileName: fileName, mimeType: mimeType)
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
          
          self.parentViewModel.imageDataCache.setObject(
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

extension ServiceListCollectionViewCellViewModel {
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
