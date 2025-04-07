//
//  OnboardingLocationPermissionViewController.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 24.08.22.
//

import OSCAEssentials
import UIKit
import Combine

final class OnboardingLocationPermissionViewController: UIViewController, Alertable {
  
  @IBOutlet private var locationImage: UIImageView!
  @IBOutlet private var headerLabel: UILabel!
  @IBOutlet private var bodyLabel: UILabel!
  @IBOutlet private var grantButton: UIButton!
  @IBOutlet private var pagedControl: UIPageControl!
  @IBOutlet private var nextButton: UIButton!
  
  private var viewModel: OnboardingLocationPermissionViewModel!
  private var bindings = Set<AnyCancellable>()
  
  let pageIndex: Int = 4
  
  override func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLoad()
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.view.backgroundColor = .accent
    
    let locationImage = UIImage(named: self.viewModel.locationImage,
                                in: OSCASolingen.bundle,
                                with: nil)
    self.locationImage.image = locationImage
    
    self.headerLabel.text = self.viewModel.title
    self.headerLabel.textColor = .black
    
    self.bodyLabel.text = self.viewModel.content
    self.bodyLabel.textColor = .black
    self.bodyLabel.numberOfLines = 0
    
    self.grantButton.setTitle(self.viewModel.grantLocationTitle,
                              for: .normal)
    self.grantButton.setTitleColor(.primary, for: .normal)
    self.grantButton.setTitleColor(.white, for: .disabled)
    self.grantButton.backgroundColor = .white
    self.grantButton.layer.borderColor = UIColor.white.cgColor
    self.grantButton.layer.borderWidth = 1.0
    self.grantButton.layer.cornerRadius = 10
    
    self.pagedControl.numberOfPages = 6
    self.pagedControl.currentPage = pageIndex
    self.pagedControl.pageIndicatorTintColor = .white
    self.pagedControl.currentPageIndicatorTintColor = .primary
    self.pagedControl.addTarget(
      self,
      action: #selector(onPageValueDidChange(_:)),
      for: .valueChanged
    )
    
    let nextImage = UIImage(systemName: "chevron.right")?
      .withRenderingMode(.alwaysTemplate)
    self.nextButton.setImage(nextImage, for: .normal)
    self.nextButton.tintColor = .primary
  }
  
  private func setupBindings() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel.$isLocationShared
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] granted in
        guard let `self` = self else { return }
        
        self.grantButton.setTitle(self.viewModel.grantLocationTitle,
                                  for: .disabled)
        self.grantButton.backgroundColor = .accent
        self.grantButton.isEnabled = false
        
        if !granted {
          self.showAlert(title: self.viewModel.alertTitle,
                         message: self.viewModel.alertMessage)
        }
      })
      .store(in: &self.bindings)
  }
  
  @objc func onPageValueDidChange(_ sender: UIPageControl) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if(sender.currentPage == self.pageIndex) { return }
    if(sender.currentPage > self.pageIndex) {
      viewModel.nextButtonTouch()
    } else {
      viewModel.previousButtonTouch()
    }
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
  
  @IBAction private func grantButtonTouch(_: UIButton) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel.grantButtonTouch()
  }
  
  @IBAction private func nextButtonTouch(_ sender: UIButton) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel.nextButtonTouch()
  }
}

extension OnboardingLocationPermissionViewController: StoryboardInstantiable {
  // MARK: - Lifecycle
  static func create(with viewModel: OnboardingLocationPermissionViewModel) -> OnboardingLocationPermissionViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}
