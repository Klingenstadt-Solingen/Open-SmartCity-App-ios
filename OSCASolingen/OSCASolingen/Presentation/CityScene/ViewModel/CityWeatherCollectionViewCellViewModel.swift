//
//  CityWeatherCollectionViewCellViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 24.06.22.
//

import Foundation
import OSCAWeather

final class CityWeatherCollectionViewCellViewModel {
  var station: OSCAWeatherObserved
  var temperatureString: String {
    guard let value = station.valueArray?.weatherValues
      .first(where: { $0.type == .temperature })?.value,
          let unit = station.valueArray?.weatherValues
      .first(where: { $0.type == .temperature })?.unit else { return "n/a" }
    return "\(NSNumber(value: value).toString(digits: 1))\(unit)"
  }
  
  var rainString: String {
    guard let value = station.valueArray?.weatherValues
      .first(where: { $0.type == .precipitation })?.value,
          let unit = station.valueArray?.weatherValues
      .first(where: { $0.type == .precipitation })?.unit else { return "n/a" }
    return "\(NSNumber(value: value).toString(digits: 1))\(unit)"
  }
  
  var stationName: String {
    return station.shortName ?? "n/a"
  }
  
  var isRaining: Bool {
    guard let value = station.valueArray?.weatherValues
      .first(where: { $0.type == .precipitation })?.value else { return false }
    return value > 0.3
  }
  
  private let cellRow: Int
  
  public init(weatherStation: OSCAWeatherObserved,
              at row: Int) {
    station = weatherStation
    cellRow = row
  }
}

extension NSNumber {
  func toString(digits: Int) -> String {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.maximumFractionDigits = digits
    formatter.usesGroupingSeparator = true
    formatter.numberStyle = .decimal
    
    return formatter.string(from: self) ?? "n/a"
  }
}
