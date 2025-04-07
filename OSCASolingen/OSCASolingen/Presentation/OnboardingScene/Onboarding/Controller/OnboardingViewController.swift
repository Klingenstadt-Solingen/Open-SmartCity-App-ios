//
//  OnboardingViewController.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import OSCAEssentials
import UIKit

final class OnboardingViewController: UIViewController {
  
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subtitleLabel: UILabel!
  @IBOutlet private var contentLabel: UILabel!
  @IBOutlet private var pagedControl: UIPageControl!
  @IBOutlet private var nextButton: UIButton!
  
  private var viewModel: OnboardingViewModel!
  
  let pageIndex: Int = 0
  
  override func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLoad()
    self.setupViews()
  }
  
  private func setupViews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.view.backgroundColor = .white
    
    self.imageView.image = UIImage(named: self.viewModel.image,
                                   in: OSCASolingen.bundle,
                                   with: nil)
    
    self.titleLabel.text = self.viewModel.title
    self.titleLabel.textColor = .gray
    
    self.subtitleLabel.text = self.viewModel.subtitle
    self.subtitleLabel.textColor = .primary
    
    self.contentLabel.text = self.viewModel.content
    self.contentLabel.textColor = .gray
    self.contentLabel.numberOfLines = 0
    
    self.pagedControl.numberOfPages = 6
    self.pagedControl.currentPage = pageIndex
    self.pagedControl.pageIndicatorTintColor = .primary
    self.pagedControl.currentPageIndicatorTintColor = .gray.darker()
    self.pagedControl.addTarget(
      self,
      action: #selector(onPageValueDidChange(_:)),
      for: .valueChanged
    )
    
    let image = UIImage(systemName: "chevron.right")?
      .withRenderingMode(.alwaysTemplate)
    self.nextButton.setImage(image, for: .normal)
    self.nextButton.tintColor = .primary
  }
  
  override func viewWillAppear(_ animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      tintColor: .primary,
      titleTextColor: .primary)
    self.pagedControl.currentPage = pageIndex
  }
  
  @IBAction private func nextButtonTouch(_ sender: UIButton) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel.nextButtonTouch()
  }
  
  @objc func onPageValueDidChange(_ sender: UIPageControl) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.nextButtonTouch()
  }
}

extension OnboardingViewController: StoryboardInstantiable {
  // MARK: - Lifecycle
  static func create(with viewModel: OnboardingViewModel) -> OnboardingViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}
