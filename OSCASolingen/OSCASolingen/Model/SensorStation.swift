//
//  SensorStation.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 22.11.21.
//  Reviewed by Stephan Breidenbach on 13.06.2022
//

import OSCAEssentials
import Foundation
/**
 Parse-Class: "SensorStation"
 */
public struct SensorStation{
  /// Auto generated id
  public private(set) var objectId                        : String?
  /// UTC date when the object was created
  public private(set) var createdAt                       : Date?
  /// UTC date when the object was changed
  public private(set) var updatedAt                       : Date?
  
  public var relativeAirHumidity           : Double?       // Parse-name: "relative_luftfeuchte"
  public var relativeAirHumidityAverage    : Double?       // Parse-name: "relative_LuftfeuchteAverage"
  public var windSpeedKmh                  : Double?       // Parse-name: "windgeschwindigkeit_kmh"
  public var windSpeedAverageKmh           : Double?       // Parse-name: "windgeschwindigkeit_kmhAverage"
  public var precipitationIntensity        : Double?       // Parse-name: "niederschlagsintensitaet"
  public var precipitationIntensityAverage : Double?       // Parse-name: "niederschlagsintensitaetAverage"
  public var stationId                     : Int?          // Parse-name: "STATION_ID"
  public var stationLocaton                : String?       // Parse-name: "STATION_ORT"
  public var airTemperature                : Double?       // Parse-name: "lufttemperatur"
  public var airTemperatureAverage         : Double?       // Parse-name: "lufttemperaturAverage"
  public var airPressureRelative           : Double?       // Parse-name: "relativer_luftdruck"
  public var airPressureRelativeAverage    : Double?       // Parse-name: "relativer_luftdruckAverage"
  public var district                      : String?       //
  public var sensorInfo                    : String?       // Parse-name: "SENSOR_INFO"
  public var uv_index                      : Double?       //
  public var windDirection                 : String?       // Parse-name: "windrichtung"
  public var geopoint                      : OSCAGeoPoint? //
}// end struct SensorStation

extension SensorStation: OSCAParseClassObject {}

extension SensorStation: Equatable {}

extension SensorStation {
  /// Parse class name
  public static var parseClassName : String { return "SensorStation" }
}// end extension SensorStation
