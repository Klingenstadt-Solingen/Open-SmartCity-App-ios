//
//  OSCAAppointmentsCellViewModel.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 22.11.22.
//

import OSCAEssentials
// After seperating from core app import OSCAAppointments
import Foundation
import Combine

public final class OSCAAppointmentsCellViewModel {
  
  let dependencies       : OSCAAppointmentsUI.Dependencies
  private let appointment: OSCAAppointment
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  init(dependencies: OSCAAppointmentsUI.Dependencies,
       appointment : OSCAAppointment) {
    self.dependencies = dependencies
    self.appointment  = appointment
  }
  
  // MARK: - OUTPUT
  
  @Published private(set) var imageData: Data? = nil
  
  var title: String    { self.appointment.title ?? "" }
  var subtitle: String { self.appointment.subtitle ?? "" }
  var imageDataFromCache: Data? {
    guard let objectId = self.appointment.objectId
    else { return nil }
    let imageData = self.dependencies.dataModule.dataCache
      .object(forKey: NSString(string: objectId))
    return imageData as Data?
  }
  
  // MARK: - Private
  
  private func fetchImage() {
    guard var iconPath = self.appointment.iconPath
    else { return }
    
    if iconPath.last == "/" {
      iconPath.removeLast()
    }
    
    guard let objectId = self.appointment.objectId,
          let baseURL = URL(string: iconPath),
          let fileName = self.appointment.iconName,
          let mimeType = self.appointment.iconMimetype
    else { return }
    
    self.dependencies.dataModule.fetchImage(
      objectId: objectId,
      baseURL: baseURL,
      fileName: fileName,
      mimeType: mimeType)
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
        self.imageData = fetchedImage.imageData
        guard let imageData = fetchedImage.imageData
        else { return }
        self.dependencies.dataModule.dataCache.setObject(
          NSData(data: imageData),
          forKey: NSString(string: objectId))
        
      case let .failure(error):
        print("\(Self.self): receivedValue: failure \(#function) -- Error: \(error)")
      }
    }
    .store(in: &self.bindings)
  }
}

// MARK: - View Model Input
extension OSCAAppointmentsCellViewModel {
  func fill() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let imageDataFromCache = self.imageDataFromCache {
      self.imageData = imageDataFromCache
      
    } else {
      self.fetchImage()
    }
  }
}
