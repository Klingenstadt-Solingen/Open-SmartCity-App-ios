//
//  ServiceListCollectionViewCell.swift
//  OSCASolingen

//  Created by Mammut Nithammer on 23.06.22.
//

import Combine
import OSCAEssentials
import UIKit

final class ServiceListCollectionViewCell: UICollectionViewCell {
  @IBOutlet var containerView: UIView!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subtitleLabel: UILabel!
  
  public static let identifier = String(describing: ServiceListCollectionViewCell.self)
  private var bindings = Set<AnyCancellable>()
  
  public var viewModel: ServiceListCollectionViewCellViewModel! {
    didSet {
      setupView()
      setupBindings()
      viewModel.didSetViewModel()
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
    
    titleLabel.text = viewModel.title
    subtitleLabel.text = viewModel.subtitle
    
    imageView.image = viewModel.imageDataFromCache == nil
    ? UIImage(named: "placeholder_image",
              in: OSCASolingen.bundle,
              with: .none)
    : UIImage(data: viewModel.imageDataFromCache!)
    imageView.contentMode = .scaleAspectFill
  }
  
  private func setupBindings() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.$imageData
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] imageData in
        guard let `self` = self,
              let imageData = imageData
        else { return }
        
        self.imageView.image = UIImage(data: imageData)
      })
      .store(in: &bindings)
  }
}
