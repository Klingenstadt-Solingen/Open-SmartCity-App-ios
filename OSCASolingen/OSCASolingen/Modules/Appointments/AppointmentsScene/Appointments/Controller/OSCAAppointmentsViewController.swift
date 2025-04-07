//
//  OSCAAppointmentsViewController.swift
//  OSCAAppointmentsUI
//
//  Created by Ömer Kurutay on 22.11.22.
//

import OSCAEssentials
// After seperating from core app import OSCAAppointments
import UIKit
import Combine

public final class OSCAAppointmentsViewController: UIViewController, ActivityIndicatable, Alertable {
  
  @IBOutlet private var collectionView: UICollectionView!
  
  private typealias DataSource = UICollectionViewDiffableDataSource<OSCAAppointmentsViewModel.Section, OSCAAppointment>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<OSCAAppointmentsViewModel.Section, OSCAAppointment>
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var viewModel: OSCAAppointmentsViewModel!
  private var bindings = Set<AnyCancellable>()
  private var dataSource: DataSource!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.setupViews()
    self.setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCAAppointmentsUI.configuration.colorConfig.backgroundColor
    self.view.addSubview(self.activityIndicatorView)
    
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.activityIndicatorView.heightAnchor.constraint(equalToConstant: 100.0),
      self.activityIndicatorView.widthAnchor.constraint(equalToConstant: 100.0),
    ])
    
    self.collectionView.delegate = self
    self.collectionView.backgroundColor = .clear
  }
  
  private func setupBindings() {
    self.viewModel.$appointments
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] appointments in
        guard let `self` = self else { return }
        self.configureDataSource()
        self.updateSections(appointments)
      })
      .store(in: &self.bindings)
    
    let stateValueHandler: (OSCAAppointmentsViewModel.State) -> Void = { [weak self] state in
      guard let `self` = self else { return }
      
      switch state {
      case .loading:
        self.startLoading()
        
      case .finishedLoading:
        self.finishLoading()
        
      case .error:
        self.finishLoading()
        self.showAlert(
          title: self.viewModel.alertTitleError,
          message: "Die Daten konnten nicht geladen werden.",
          actionTitle: self.viewModel.alertActionConfirm)
      }
    }
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAAppointmentsUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAAppointmentsUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAAppointmentsUI.configuration.colorConfig.navigationBarColor)
  }
  
  private func configureDataSource() {
    self.dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { (collectionView, indexPath, appointment) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAAppointmentsCellView.identifier,
          for: indexPath) as? OSCAAppointmentsCellView
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAAppointmentsCellViewModel(
          dependencies: self.viewModel.dependencies,
          appointment: appointment)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
  
  private func updateSections(_ items: [OSCAAppointment]) {
    var snapshot = Snapshot()
    snapshot.appendSections([.appointment])
    snapshot.appendItems(items)
    self.dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func startLoading() {
    self.collectionView.isUserInteractionEnabled = false
    
    self.activityIndicatorView.isHidden = false
    self.activityIndicatorView.startAnimating()
  }
  
  private func finishLoading() {
    self.collectionView.isUserInteractionEnabled = true
    
    self.activityIndicatorView.stopAnimating()
  }
}

// MARK: instantiate view controller
extension OSCAAppointmentsViewController: StoryboardInstantiable {
  /// function call: var vc = OSCAAppointmentsViewController.create(viewModel)
  public static func create(with viewModel: OSCAAppointmentsViewModel) -> OSCAAppointmentsViewController {
    #if DEBUG
      print("\(String(describing: self)): \(#function)")
    #endif
    var bundle: Bundle
    #if SWIFT_PACKAGE
      bundle = OSCAAppointmentsUI.bundle
    #else
      bundle = Bundle(for: Self.self)
    #endif
    let vc = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }
}

// MARK: Collection View Delegate
extension OSCAAppointmentsViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.viewModel.didSelectItem(at: indexPath.row)
  }
}

// MARK: Collection View Delegate Flow Layout
extension OSCAAppointmentsViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenWidth = collectionView.frame.width
    
    let minCells: CGFloat = 2
    var maxWidth: CGFloat = 220
    let space: CGFloat = 16
    
    var cellCount = ceil((screenWidth - (2 * space)) / (maxWidth + (space / 2)))
    
    if cellCount < minCells {
      maxWidth = (screenWidth / minCells) - ((minCells - 1) * space)
      cellCount = screenWidth / (maxWidth + (space / 2))
    }
    
    let cellWidth = floor((screenWidth - (2 * space) - ((cellCount - 1) * space)) / cellCount)
    let cellHeight = floor(cellWidth / 21 * 13)
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
}
