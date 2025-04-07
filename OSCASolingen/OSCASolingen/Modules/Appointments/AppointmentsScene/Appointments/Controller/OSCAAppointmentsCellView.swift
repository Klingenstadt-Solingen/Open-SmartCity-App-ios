//
//  OSCAAppointmentsCellView.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 22.11.22.
//

import OSCAEssentials
import UIKit
import Combine

final class OSCAAppointmentsCellView: UICollectionViewCell {
  static let identifier = String(describing: OSCAAppointmentsCellView.self)
  
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtitleLabel: UILabel!
  @IBOutlet private var imageView: UIImageView!
  
  private var bindings = Set<AnyCancellable>()
  private var viewModel: OSCAAppointmentsCellViewModel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.addShadow(with: OSCAAppointmentsUI.configuration.shadow)
    
    self.contentView.backgroundColor = OSCAAppointmentsUI.configuration.colorConfig.secondaryBackgroundColor
    self.contentView.layer.cornerRadius = OSCAAppointmentsUI.configuration.cornerRadius
    self.contentView.layer.masksToBounds = true
    
    self.titleLabel.font = OSCAAppointmentsUI.configuration.fontConfig.bodyLight
    self.titleLabel.textColor = OSCAAppointmentsUI.configuration.colorConfig.textColor
    self.titleLabel.numberOfLines = 2
    
    self.subtitleLabel.font = OSCAAppointmentsUI.configuration.fontConfig.bodyLight
    self.subtitleLabel.textColor = OSCAAppointmentsUI.configuration.colorConfig.whiteDarker
    self.subtitleLabel.numberOfLines = 2
    
    self.imageView.tintColor = OSCAAppointmentsUI.configuration.colorConfig.grayDark
    self.imageView.contentMode = .scaleAspectFit
    self.imageView.layer.cornerRadius = OSCAAppointmentsUI.configuration.cornerRadius
  }
  
  func fill(with viewModel: OSCAAppointmentsCellViewModel) {
    self.viewModel = viewModel
    
    self.titleLabel.text = viewModel.title
    self.subtitleLabel.text = viewModel.subtitle
    
    self.imageView.image = viewModel.imageDataFromCache == nil
      ? UIImage(named: "placeholder_image",
                in: OSCAAppointmentsUI.bundle,
                with: .none)
      : UIImage(data: viewModel.imageData!)
    
    self.setupBindings()
    viewModel.fill()
  }
  
  private func setupBindings() {
    self.viewModel.$imageData
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] imageData in
        guard let `self` = self,
              let imageData = imageData
        else { return }
        
        self.imageView.image = UIImage(data: imageData)
      })
      .store(in: &self.bindings)
  }
}
