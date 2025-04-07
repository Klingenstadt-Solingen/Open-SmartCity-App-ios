//
//  OnboardingNotificationViewController.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 24.08.22.
//

import OSCAEssentials
import UIKit
import Combine

final class OnboardingNotificationViewController: UIViewController {
  /// controller's activity indicator
  public lazy var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView.init(style: .large,
                                                                                            color: .darkGray)
  
  @IBOutlet private var notificationImage: UIImageView!
  @IBOutlet private var headerLabel: UILabel!
  @IBOutlet private var bodyLabel: UILabel!
  @IBOutlet private var grantButton: UIButton!
  @IBOutlet private var pagedControl: UIPageControl!
  @IBOutlet private var nextButton: UIButton!
  
  private var viewModel: OnboardingNotificationViewModel!
  private var bindings = Set<AnyCancellable>()
  
  let pageIndex: Int = 3
  
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
    self.view.backgroundColor = .primary
    
    let notificationImage = UIImage(named: self.viewModel.notificationImage,
                                    in: OSCASolingen.bundle,
                                    with: nil)
    self.notificationImage.image = notificationImage
    
    self.headerLabel.text = self.viewModel.title
    self.headerLabel.textColor = .white
    
    self.bodyLabel.text = self.viewModel.content
    self.bodyLabel.textColor = .white
    self.bodyLabel.numberOfLines = 0
    
    self.grantButton.setTitle(self.viewModel.grantNotificationTitle,
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
    self.pagedControl.currentPageIndicatorTintColor = .accent
    self.pagedControl.addTarget(
      self,
      action: #selector(onPageValueDidChange(_:)),
      for: .valueChanged
    )
    
    let nextImage = UIImage(systemName: "chevron.right")?
      .withRenderingMode(.alwaysTemplate)
    self.nextButton.setImage(nextImage, for: .normal)
    self.nextButton.tintColor = .accent
  }
  
  private func setupBindings() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel.$isNotificationGranted
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] granted in
        guard let `self` = self else { return }
        
        self.grantButton.setTitle(self.viewModel.activatedNotificationTitle,
                                  for: .disabled)
        self.grantButton.backgroundColor = .primary
        self.grantButton.isEnabled = false
      })
      .store(in: &self.bindings)
  }
  
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
}

extension OnboardingNotificationViewController: StoryboardInstantiable {
  // MARK: - Lifecycle
  static func create(with viewModel: OnboardingNotificationViewModel) -> OnboardingNotificationViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OnboardingNotificationViewController: ActivityIndicatable {
  /// configure activity indicator view
  /// * add activity indicator subview
  /// * define layout constraints
  func setupActivityIndicator() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      self.activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      self.activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      self.activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    ])
  }// end func setupAcitivityIndicator
}
