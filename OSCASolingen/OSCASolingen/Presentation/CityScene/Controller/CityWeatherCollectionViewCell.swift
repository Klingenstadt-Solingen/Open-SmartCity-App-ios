//
//  CityWeatherCollectionViewCell.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 24.06.22.
//

import Combine
import OSCAEssentials
import UIKit

final class CityWeatherCollectionViewCell: UICollectionViewCell {
  @IBOutlet var temperatureLabel: UILabel!
  @IBOutlet var stationNameLabel: UILabel!
  @IBOutlet var rainLabel: UILabel!
  @IBOutlet var sunrainImageView: UIImageView!
  
  public static let identifier = String(describing: CityWeatherCollectionViewCell.self)
  private var bindings = Set<AnyCancellable>()
  
  public var viewModel: CityWeatherCollectionViewCellViewModel! {
    didSet {
      setupView()
    }
  }
  
  private func setupView() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    contentView.backgroundColor = .systemBackground
    contentView.layer.cornerRadius = 10
    contentView.layer.masksToBounds = true
    
    addShadow(with: OSCAShadowSettings(opacity: 0.2,
                                       radius: 10,
                                       offset: CGSize(width: 0, height: 2)))
    
    temperatureLabel.text = viewModel.temperatureString
    rainLabel.text = viewModel.rainString
    stationNameLabel.text = viewModel.stationName
    
    sunrainImageView.image = viewModel.isRaining ? UIImage(systemName: "cloud.rain.fill") : UIImage(systemName: "sun.max.fill")
    sunrainImageView.tintColor = viewModel.isRaining ? .systemGray2 : .systemOrange
    sunrainImageView.contentMode = .scaleAspectFill
  }
}
