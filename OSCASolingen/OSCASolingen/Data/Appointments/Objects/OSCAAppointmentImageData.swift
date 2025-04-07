//
//  OSCAAppointmentImageData.swift
//  OSCAAppointments
//
//  Created by Ömer Kurutay on 19.02.23.
//

import OSCAEssentials
import Foundation

public struct OSCAAppointmentImageData: OSCAImageData {
  public var objectId: String?
  public var imageData: Data?
  
  public init(objectId: String, imageData: Data) {
    self.imageData = imageData
    self.objectId = objectId
  }
}
