//
//  ServiceListViewController.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 23.06.22.
//  Reviewed by Stephan Breidenbach on 16.02.23
//

import Combine
import OSCAEssentials
import UIKit

final class ServiceListViewController: UIViewController, Alertable, ActivityIndicatable {
  /// activity indicator view
  public var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView(style: .large)
  /// collection view
  @IBOutlet var collectionView: UICollectionView!

  private typealias DataSource = UICollectionViewDiffableDataSource<ServiceListViewModel.Section, ServiceMenu>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<ServiceListViewModel.Section, ServiceMenu>
  private var viewModel: ServiceListViewModel!
  private var bindings = Set<AnyCancellable>()
  private var dataSource: DataSource!
  
  override public func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidLoad()
    setupViews()
    setupBindings()
    setupSelectedItemBinding()
    viewModel.viewDidLoad()
  }// end override public func viewDidLoad
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    OSCAMatomoTracker.shared.trackNavigation(self, true)
  }
  
  /// setup view
  /// * color
  /// * search controller
  /// * navigation item
  /// * activity indicator
  /// * collection view
  private func setupViews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // navigation item
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = viewModel.screenTitle
    // setup collection view
    setupCollectionView()
  }// end setupViews
  
  /// setup the collection view:
  /// * delegation
  /// * color
  /// * view cell
  /// * layout
  /// * [pull to refresh control](https://mobikul.com/pull-to-refresh-in-swift/)
  private func setupCollectionView() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // delegation
    collectionView.delegate = self
    // color
    collectionView.backgroundColor = .systemBackground
    // view cell
    let bundle = OSCASolingen.bundle
    collectionView.register(UINib(nibName: "ServiceListCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: ServiceListCollectionViewCell.identifier)
    // layout
    collectionView.collectionViewLayout = createLayout()
    // pull to refresh
    collectionView.refreshControl = UIRefreshControl()
    // add target to UIRefreshControl
    collectionView.refreshControl?.addTarget(self,
                                             action: #selector(callPullToRefresh),
                                             for: .valueChanged)
  }// end private func setupCollectionView
  
  private func createLayout() -> UICollectionViewLayout {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(80))
    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }// end private func createLayout
  
  private func setupBindings() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.$items
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] menuItem in
        guard let `self` = self else { return }
        self.configureDataSource()
        self.updateSections(menuItem)
      })
      .store(in: &bindings)
    let startLoading = {
      self.collectionView.isUserInteractionEnabled = false
      self.showActivityIndicator()
    }// end let start loading closure
    
    let finishLoading = {
      self.collectionView.isUserInteractionEnabled = true
      self.hideActivityIndicator()
    }// end finish loading closure
    
    let stateValueHandler: (ServiceListViewModelState) -> Void = { [weak self] state in
      guard let `self` = self else { return }
      
      switch state {
      case .loading:
        startLoading()
        
      case .finishedLoading:
        finishLoading()
        
      case let .error(error):
        finishLoading()
        self.showAlert(
          title: self.viewModel.alertTitleError,
          message: error.localizedDescription,
          actionTitle: self.viewModel.alertActionConfirm)
      }// end switch case
    }// end let state value handler
    
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &bindings)
  }// end private func setupBinding
  
  /// [Apple documentation ui refresh control](https://developer.apple.com/documentation/uikit/uirefreshcontrol)
  @objc func callPullToRefresh(){
    viewModel.callPullToRefresh()
    DispatchQueue.main.async {
      self.collectionView.refreshControl?.endRefreshing()
    }// end
  }// end @objc func callPullToRefresh
  
  private func updateSections(_ items: [ServiceMenu]) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var snapshot = Snapshot()
    snapshot.appendSections([.serviceMenuItems])
    snapshot.appendItems(items)
    dataSource.apply(snapshot, animatingDifferences: true)
  }// end private func updateSections
}// end final class ServiceListViewController

extension ServiceListViewController {
  private func configureDataSource() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { (collectionView, indexPath, menuItem) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ServiceListCollectionViewCell.identifier,
          for: indexPath) as? ServiceListCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.viewModel = ServiceListCollectionViewCellViewModel(
          viewModel: self.viewModel,
          listItem: menuItem,
          at: indexPath.row)
        
        return cell
      })
  }// end private func configureDataSource
}// end extension final class ServiceListViewController

extension ServiceListViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.didSelectItem(at: indexPath.row)
  }// end public func collection vie did select item at
}// end extension final class ServiceListViewController

// MARK: - instantiate view conroller

extension ServiceListViewController: StoryboardInstantiable {
  public static func create(with viewModel: ServiceListViewModel) -> ServiceListViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }// end public static func create
}// end extension final class ServiceListViewController

// MARK: - Deeplinking
extension ServiceListViewController {
  
  private func setupSelectedItemBinding() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.$selectedItem
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] selectedItem in
        guard let `self` = self,
              let selectedItem = selectedItem
        else { return }
        self.selectItem(with: selectedItem)
      })
      .store(in: &bindings)
  }// end private func setupSelectedItemBinding
  
  private func selectItem(with index: Int) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let indexPath: IndexPath = IndexPath(row: index, section: 0)
    collectionView.selectItem(at: indexPath,
                              animated: true,
                              scrollPosition: .top)
    self.collectionView(collectionView, didSelectItemAt: indexPath)
  }// end private func selectItem with index
  
  func didReceiveDeeplink(with url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.didReceiveDeeplink(with: url)
  }// end func didReceiveDeeplinkDetail
}// end extension final class ServiceListViewController
