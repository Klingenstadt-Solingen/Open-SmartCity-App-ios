//
//  OnboardingPrivacyPolicyViewController.swift
//  OSCASolingen
//
//  Created by Ömer Kurutay on 23.08.22.
//

import OSCAEssentials
import UIKit
import Combine

final class OnboardingPrivacyPolicyViewController: UIViewController {
  /// controller's activity indicator
  public lazy var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView.init(style: .large,
                                                                                            color: .darkGray)
  @IBOutlet private var privacyHeaderLabel: UILabel!
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var textContainer: UIView!
  @IBOutlet private var privacyTextView: UITextView!
  @IBOutlet private var textViewHeight: NSLayoutConstraint!
  @IBOutlet private var pagedControl: UIPageControl!
  @IBOutlet private var nextButton: UIButton!
  
  private var viewModel: OnboardingPrivacyPolicyViewModel!
  private var bindings = Set<AnyCancellable>()
  
  let pageIndex: Int = 2
  
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
    setupActivityIndicator()
    self.view.backgroundColor = .accent
    
    self.privacyHeaderLabel.text = self.viewModel.title
    self.privacyHeaderLabel.textColor = .black
    
    self.scrollView.backgroundColor = .clear
    
    self.textContainer.backgroundColor = .clear
    
    self.privacyTextView.textColor = .black
    self.privacyTextView.isScrollEnabled = false
    self.privacyTextView.textContainerInset = .zero
    self.privacyTextView.textContainer.lineFragmentPadding = 0
    let sizeThatShouldFitTheContent = self.privacyTextView.sizeThatFits(self.privacyTextView.frame.size)
    self.textViewHeight.constant = sizeThatShouldFitTheContent.height
    
    self.privacyTextView.text = ""
    self.privacyTextView.textColor = .black
    self.privacyTextView.linkTextAttributes = [.foregroundColor: UIColor.primary]
    
    self.textViewHeight.constant = self.privacyTextView.sizeThatFits(self.privacyTextView.frame.size).height
    self.view.layoutIfNeeded()
    
    self.pagedControl.numberOfPages = 6
    self.pagedControl.currentPage = 2
    self.pagedControl.pageIndicatorTintColor = .white
    self.pagedControl.currentPageIndicatorTintColor = .primary
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
  
  private func setupBindings() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let viewStateLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.showActivityIndicator()
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      self.hideActivityIndicator()
    }// end let viewStateFinishedLoading
    
    let viewStateError: (Error) -> Void = {[weak self] error in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function): \(error.localizedDescription)")
#endif
      self.hideActivityIndicator()
    }
    
    let viewStateHandler: (OnboardingPrivacyPolicyViewModelState) -> Void = {[weak self] viewModelState in
      guard self != nil else { return }
      switch viewModelState {
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case let .error(error):
        viewStateError(error)
      }// end switch case
    }// end viewStateHandler
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: viewStateHandler)
      .store(in: &self.bindings)
    
    self.viewModel.$privacy
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] privacy in
        guard let `self` = self,
              let privacy = privacy
        else { return }
        self.privacyTextView.attributedText = privacy
      })
      .store(in: &self.bindings)
  }
  
  override func viewDidLayoutSubviews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLayoutSubviews()
    self.textViewHeight.constant = self.privacyTextView.sizeThatFits(self.privacyTextView.frame.size).height
    self.view.layoutIfNeeded()
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
}

extension OnboardingPrivacyPolicyViewController: StoryboardInstantiable {
  // MARK: - Lifecycle
  static func create(with viewModel: OnboardingPrivacyPolicyViewModel) -> OnboardingPrivacyPolicyViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OnboardingPrivacyPolicyViewController: ActivityIndicatable {
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
}// end extension final class OnboardingPrivacyPolicyViewController
