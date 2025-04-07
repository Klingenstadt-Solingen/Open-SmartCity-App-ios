//
//  LaunchViewController.swift
//  
//
//  Created by Stephan Breidenbach on 17.10.22.
//

import OSCAEssentials
import UIKit
import Combine

public final class LaunchViewController: UIViewController {
  /// controller's activity indicator
  public lazy var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView.init(style: .large,
                                                                                            color: .darkGray)
  /// app flow
  var solingenAppFlow: SolingenAppFlow!
  /// controller's view model
  var viewModel: LaunchViewModel!
  /// controller's bindings
  private var bindings = Set<AnyCancellable>()
  /// bind controller's view model
  private func bind(to viewModel: LaunchViewModel) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let viewStateFirstStart: () -> Void = {[weak self] in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: descide launch indicator")
      //self.showActivityIndicator()
      self.viewModel.firstStart()
    }// end let viewStateFirstStart
    
    let viewStateLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
      #warning("TODO: descide launch indicator")
      //self.showActivityIndicator()
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
#warning("TODO: descide launch indicator")
      //self.hideActivityIndicator()
    }// end let viewStateFinishedLoading
    
    let viewStateShowOnboarding: () -> Void = {
      [weak self] in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: descide launch indicator")
      //self.hideActivityIndicator()
      self.viewModel.showOnboarding()
    }// end let viewStateShowOnboarding
    
    let viewStateShowMain: () -> Void = {
      [weak self] in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: descide launch indicator")
      //self.hideActivityIndicator()
      self.viewModel.showMain()
    }// end let viewStateShowMain
    
    let viewStateShowLogin: () -> Void = {
      [weak self] in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: descide launch indicator")
      //self.hideActivityIndicator()
    }// end let viewStateShowLogin
    
    let viewStateError: (OSCASGError, @escaping(() -> Void)) -> Void = {[weak self] oscaSGError, retryHandler in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: descide launch indicator")
      //self.hideActivityIndicator()
      self.handle(oscaSGError,
                  from: self,
                  retryHandler: retryHandler)
    }// end let viewStateError
    
    let stateValueHandler: (LaunchViewModel.State?) -> Void = {[weak self] viewModelState in
      guard self != nil,
            let viewModelState = viewModelState else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      switch  viewModelState {
      case let .firstStart:
        viewStateFirstStart()
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case let .showMain:
        viewStateShowMain()
      case .showLogin:
        viewStateShowLogin()
      case .showOnboarding:
        viewStateShowOnboarding()
      case let .error(oscaSGError, retryHandler):
        viewStateError(oscaSGError, retryHandler)
      }// end switch case
    }// end let stateValueHandler
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }// end private func bind to view model
  
  private func setupViews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    setupActivityIndicator()
  }// end private func setupViews
  
  /// `LaunchViewController lifecycle method`
  public override func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLoad()
    setupViews()
    setupSolingenAppFlowDelegate()
    bind(to: viewModel)
    viewModel.viewDidLoad()
  }// end func viewDidLoad
  
  /// `LaunchViewController lifecycle method`
  public override func viewDidAppear(_ animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidAppear(animated)
    viewModel.viewDidAppear()
  }// end func viewDidAppear
  
  /// `LaunchViewController lifecycle method`
  public override func viewWillDisappear(_ animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
  }// end func viewWillDisappear
  
  /// `LaunchViewController lifecycle method`
  public override func viewDidDisappear(_ animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidDisappear(animated)
    viewModel.viewDidDisappear()
  }// end func viewDidDisappear
  
  /// `LaunchViewController lifecycle method`
  public override func viewWillLayoutSubviews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewWillLayoutSubviews()
    viewModel.viewWillLayoutSubviews()
  }// end func viewWillLayoutSubviews
  
  /// `LaunchViewController lifecycle method`
  public override func viewDidLayoutSubviews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLayoutSubviews()
    viewModel.viewDidLayoutSubviews()
  }// end func viewDidLayoutSubviews
}// end final class LaunchViewController

extension LaunchViewController: Alertable {
}// end extension final class LaunchScreenViewController

extension LaunchViewController: ActivityIndicatable {
  /// configure activity indicator view
  /// * add activity indicator subview
  /// * define layout constraints
  func setupActivityIndicator() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: descide launch indicator")
    view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      self.activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      self.activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      self.activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    ])
  }// end func setupAcitivityIndicator
}// end extension final class LaunchViewController

extension LaunchViewController: StoryboardInstantiable {
  /// function call: var vc = LaunchViewController.create(with viewModel)
  static func create(appFlow: SolingenAppFlow,
                     with viewModel: LaunchViewModel) -> LaunchViewController? {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundlePrefix: String = "de.osca.solingen.core"
    var bundle: Bundle?
#if SWIFT_PACKAGE
    bundle = Bundle.module
#else
    bundle = Bundle(identifier: bundlePrefix)
#endif
    if let bundle = bundle {
      let vc: Self = Self.instantiateViewController(bundle)
      vc.viewModel = viewModel
      vc.solingenAppFlow = appFlow
      return vc
    } else {
      return nil
    }// end if
  } // end static func create
}// end extension final class LaunchViewController

extension LaunchViewController {
  ///[based upon](https://www.swiftbysundell.com/articles/propagating-user-facing-errors-in-swift/)
  override public func handle(_ error: Error,
                              from viewController: UIViewController? = nil,
                              retryHandler: @escaping () -> Void) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    let errorString = viewModel.errorMessage(error)
    let title = viewModel.errorAlertTitleError
    let dismissTitle = viewModel.errorAlertTitleDismiss

    let alert = UIAlertController(
      title: title,
      message: errorString,
      preferredStyle: .alert
    )// end let alert
    
    alert.addAction(UIAlertAction(
      title: dismissTitle,
      style: .default
    ))// end add action
    
    switch error.resolveCategory() {
    case .retryable:
      let retryTitle = viewModel.errorAlertTitleRetry
      alert.addAction(UIAlertAction(
        title: retryTitle,
        style: .default,
        handler: { _ in retryHandler() }
      ))// end add action
    case .nonRetryable:
      break
    }// end switch case
    
    if let viewController = viewController {
      viewController.present(alert, animated: true)
    } else {
      self.present(alert, animated: true)
    }// end if
  }// end func handle error from view controller
}// end extension final class LaunchViewController
