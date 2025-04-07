//
//  OSCAImageDataRequestResource+OSCAAppointment.swift
//  OSCAAppointments
//
//  Created by Ömer Kurutay on 19.02.23.
//

import OSCANetworkService
import Foundation

extension OSCAImageDataRequestResource {
  /// OSCAImageDataRequestResource for appointment image
  /// - Parameters:
  ///    - objectId: The id of a Appointment object
  ///    - baseURL: The URL to the file
  ///    - fileName: The name of the file
  ///    - mimeType: The filename extension
  /// - Returns: A ready to use OSCAImageDataRequestResource
  static func appointmentImageData(objectId: String, baseURL: URL, fileName: String, mimeType: String) -> OSCAImageDataRequestResource<OSCAAppointmentImageData> {
    return OSCAImageDataRequestResource<OSCAAppointmentImageData>(
      objectId: objectId,
      baseURL: baseURL,
      fileName: fileName,
      mimeType: mimeType)
  }
}
