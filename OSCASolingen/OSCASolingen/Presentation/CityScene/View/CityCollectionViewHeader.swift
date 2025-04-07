//
//  CityCollectionViewHeader.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 17.06.22.
//

import UIKit

final class CityCollectionViewHeader: UICollectionReusableView {
  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var moreButton: UIButton?
  
  public static let identifier = String(describing: CityCollectionViewHeader.self)
  /// view cell's view model
  private var viewModel: CityCollectionHeaderViewModel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  } // end override func awakeFromNib
  
  func setup(with viewModel: CityCollectionHeaderViewModel) {
    self.viewModel = viewModel
    setupViews()
    
    titleLabel?.text = viewModel.title
    moreButton?.tag = viewModel.section
    moreButton?.setTitle(viewModel.buttonTitle, for: .normal)
  }
  
  private func setupViews() {
    moreButton?.setTitleColor(viewModel.colorSettings.primaryColor, for: .normal)
    titleLabel?.textColor = viewModel.colorSettings.blackColor
  } // end private func setupViews
  
  @IBAction func moreButtonTouch(sender: UIButton) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.moreButtonTouched(tag: sender.tag)
  }
}
