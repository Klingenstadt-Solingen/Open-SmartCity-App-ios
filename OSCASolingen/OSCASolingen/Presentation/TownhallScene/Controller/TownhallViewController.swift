//
//  TownhallViewController.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 21.06.22.
//  Reviewed by Stephan Breidenbach on 16.02.2023
//

import Combine
import OSCAEssentials
import UIKit

final class TownhallViewController: UIViewController, Alertable, ActivityIndicatable {
  @IBOutlet var collectionView: UICollectionView!
  
  var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView(style: .large)
  private typealias DataSource = UICollectionViewDiffableDataSource<TownhallViewModel.Section, TownhallMenu>
  private typealias Snapshot = NSDiffableDataSourceSnapshot<TownhallViewModel.Section, TownhallMenu>
  private var viewModel: TownhallViewModel!
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
    
  /// setup the view
  /// * navigation bar
  /// * activity indicator
  /// * collection view
  private func setupViews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // navigation bar
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = viewModel.screenTitle
    // activity indicator
    setupActivityIndicator()
    // collection view
    setupCollectionView()
  }// end private func setupViews
  
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
    collectionView.register(UINib(nibName: "TownhallCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: TownhallCollectionViewCell.identifier)
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
    
    let size = NSCollectionLayoutSize(
      widthDimension: .estimated(cellWidth),
      heightDimension: .estimated(cellHeight))
    let item = NSCollectionLayoutItem(layoutSize: size)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(cellHeight))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(cellCount))
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
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
    }// end startLoading
    
    let finishLoading = {
      self.collectionView.isUserInteractionEnabled = true
      self.hideActivityIndicator()
    }// end finishedLoading
    
    let stateValueHandler: (TownhallViewModelState) -> Void = { [weak self] state in
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
    }// end let stateValueHandler
    
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &bindings)
  }// end private func setupBindings
  
  /// [Apple documentation ui refresh control](https://developer.apple.com/documentation/uikit/uirefreshcontrol)
  @objc func callPullToRefresh(){
    viewModel.callPullToRefresh()
    
    DispatchQueue.main.async {
      self.collectionView.refreshControl?.endRefreshing()
    }// end
  }// end @objc func callPullToRefresh
  
  private func updateSections(_ items: [TownhallMenu]) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var snapshot = Snapshot()
    snapshot.appendSections([.townhallMenuItems])
    snapshot.appendItems(items)
    dataSource.apply(snapshot, animatingDifferences: true)
  }// end private func updateSections
}// end final class TownhallViewController

extension TownhallViewController {
  private func configureDataSource() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    dataSource = DataSource(
      collectionView: collectionView,
      cellProvider: { (collectionView, indexPath, menuItem) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TownhallCollectionViewCell.identifier,
          for: indexPath) as? TownhallCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.viewModel = TownhallCollectionViewCellViewModel(imageCache: self.viewModel.imageDataCache, oscaTownhallMenu: self.viewModel.oscaTownhallMenu, listItem: menuItem, at: indexPath.row)
        
        return cell
      })
  }// end private func configureDataSource
}// end extension final class TownhallViewController

// MARK: - UICollectionViewDelegate
extension TownhallViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.didSelectItem(at: indexPath.row)
  }// end public func collection view did select item at
}// end extension final class TownhallViewController

extension TownhallViewController: StoryboardInstantiable {
  /// function call: var vc = ModuleNavigationViewController.create(viewModel)
  static func create(with viewModel: TownhallViewModel) -> TownhallViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  } // end static func create
} // end extension final class CityViewController

// MARK: - Deeplinking
extension TownhallViewController {
  
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
}// end extension TownhallViewController

