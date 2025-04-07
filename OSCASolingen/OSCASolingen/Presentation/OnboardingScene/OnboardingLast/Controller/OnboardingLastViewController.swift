//
//  OnboardingLastViewController.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 24.08.22.
//

import OSCAEssentials
import UIKit

final class OnboardingLastViewController: UIViewController {
  
  @IBOutlet private var startImageView: UIImageView!
  @IBOutlet private var headerLabel: UILabel!
  @IBOutlet private var bodyLabel: UILabel!
  @IBOutlet private var startButton: UIButton!
  @IBOutlet private var pagedControl: UIPageControl!
  
  private var viewModel: OnboardingLastViewModel!
  
  let pageIndex: Int = 5
  
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
    let image = UIImage(named: self.viewModel.startImage,
                        in: OSCASolingen.bundle,
                        with: nil)
    self.startImageView.image = image
    
    self.headerLabel.text = self.viewModel.title
    self.headerLabel.textColor = .white
    
    self.bodyLabel.text = self.viewModel.content
    self.bodyLabel.textColor = .white
    self.bodyLabel.numberOfLines = 0
    
    self.startButton.setTitle(self.viewModel.startTitle,
                              for: .normal)
    self.startButton.setTitleColor(.primary, for: .normal)
    self.startButton.backgroundColor = .white
    self.startButton.layer.cornerRadius = 10
    
    self.pagedControl.numberOfPages = 6
    self.pagedControl.currentPage = pageIndex
    self.pagedControl.pageIndicatorTintColor = .white
    self.pagedControl.currentPageIndicatorTintColor = .accent
    self.pagedControl.addTarget(
      self,
      action: #selector(onPageValueDidChange(_:)),
      for: .valueChanged
    )
  }
  
  private func setupBindings() {}
  
  override func viewWillAppear(_ animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      tintColor: .accent,
      titleTextColor: .accent)
    self.pagedControl.currentPage = pageIndex
  }
  
  @IBAction private func startButtonTouch(_: UIButton) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel.startButtonTouch()
  }
  
  @objc func onPageValueDidChange(_ sender: UIPageControl) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if(sender.currentPage == self.pageIndex) { return }
    if(sender.currentPage > self.pageIndex) {
      viewModel.startButtonTouch()
    } else {
      viewModel.previousButtonTouch()
    }
  }
}

extension OnboardingLastViewController: StoryboardInstantiable {
  // MARK: - Lifecycle
  static func create(with viewModel: OnboardingLastViewModel) -> OnboardingLastViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}
