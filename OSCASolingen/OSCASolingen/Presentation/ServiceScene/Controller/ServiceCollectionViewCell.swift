//
//  ServiceCollectionViewCell.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 12.10.22.
//

import Combine
import OSCAEssentials
import UIKit

final class ServiceCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!
  
  public static let identifier = String(describing: ServiceCollectionViewCell.self)
  private var bindings = Set<AnyCancellable>()
  
  public var viewModel: ServiceCollectionViewCellViewModel! {
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
    subTitleLabel.text = viewModel.subTitle
    
    imageView.image = viewModel.imageDataFromCache == nil
    ? UIImage(named: "placeholder_image",
              in: OSCASolingen.bundle,
              with: .none)
    : UIImage(data: viewModel.imageDataFromCache!)
    imageView.contentMode = .scaleAspectFill
    imageView.tintColor = .systemGray2
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
}// end final class ServiceCollectionViewCell
