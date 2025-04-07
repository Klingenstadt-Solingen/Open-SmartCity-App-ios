//
//  HomeTabRootViewController.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 09.03.22.
//  Reviewed by Stephan Breidenbach on 29.08.2022
//

import UIKit
import OSCAEssentials
import Combine

public protocol HomeTabRootControllerDelegate: AnyObject{
  func navigate(url: URL) -> Void
}// end protocol HomeTabRootControllerDelegate
/**
 A tab bar interface is useful in situations where you want to provide different perspectives on the same set of data or in situations where you want to organize your app along functional lines. The key component of a tab bar interface is the presence of a tab bar view along the bottom of the screen. This view is used to initiate the navigation between your app’s different modes and can also convey information about the state of each mode.
 [`UITabBarController` programmatically](https://riptutorial.com/ios/example/32359/create-tab-bar-controller-programmatically-without-storyboard)
 */
public class HomeTabRootViewController: UITabBarController {
  // MARK: - IBOutlets
  @IBOutlet weak var homeTabBar: UITabBar?
  
  weak var tabBarDelegate: HomeTabRootControllerDelegate?
  // MARK: - private
  /// controller's activity indicator
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  /// controller's view model
  private var viewModel: HomeTabRootViewModel!
  /// controller's bindings
  private var bindings = Set<AnyCancellable>()
  
  private func bind(to viewModel: HomeTabRootViewModel) -> Void {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    let viewStateLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      self.showActivityIndicator()
    }// end let viewStateLoading
    
    let viewStateFinishedLoading: () -> Void = {[weak self] in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      self.hideActivityIndicator()
      self.updateItems()
    }// end let viewStateFinishedLoading
    
    let viewStateError: (HomeTabRootViewModel.Error) -> Void = {[weak self] viewModelError in
      guard let `self` = self else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      self.hideActivityIndicator()
      let title = self.viewModel.alertTitleError
      let message = viewModelError.localizedDescription
      let actionTitle = self.viewModel.alertActionConfirm
      self.showAlert(title: title,
                     message: message,
                     actionTitle: actionTitle)// end showAlert
    }// end let viewStateError
    
    let stateValueHandler: (HomeTabRootViewModel.State) -> Void = {[weak self] viewModelState in
      guard self != nil else { return }
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      switch  viewModelState {
      case .loading:
        viewStateLoading()
      case .finishedLoading:
        viewStateFinishedLoading()
      case let .error(viewModelError):
        viewStateError(viewModelError)
      }// end switch case
    }// end let stateValueHandler
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }// end private func bind
  
  // MARK: - private
  private func setupViews() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    setupTabBar()
  }// end private func setupViews
  
  private func setupBehaviors() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    #warning("TODO: implementation")
  }// end private func setupBehaviors
  
  private func updateItems() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.viewModel?.updateAllItems()
  }// end private func updateItems
}// end class HomeTabRootViewController

extension HomeTabRootViewController {
  public override func viewDidLoad() -> Void {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.viewDidLoad()
    //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
    setupViews()
    setupBehaviors()
    bind(to: self.viewModel)
    //setupURLBinding()
    self.viewModel.viewDidLoad()
  }// end override func viewDidLoad
  
  public override func viewWillAppear(_ animated: Bool) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewWillAppear(animated)
    self.viewModel.viewWillAppear()
  }// end override func viewWillAppear
  
  public override func viewDidAppear(_ animated: Bool) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewDidAppear(animated)
    setupURLBinding()
  }
  
  public override func viewWillDisappear(_ animated: Bool) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    super.viewWillDisappear(animated)
    self.viewModel.viewWillDisappear()
  }// end override func viewWillDisappear
}// end extension class HomeTabRootViewController

/**
 public protocol UITabBarControllerDelegate : NSObjectProtocol {
 
 
 @available(iOS 3.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
 
 @available(iOS 2.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
 
 
 @available(iOS 3.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController])
 
 @available(iOS 3.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool)
 
 @available(iOS 2.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool)
 
 
 @available(iOS 7.0, *)
 optional func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask
 
 @available(iOS 7.0, *)
 optional func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation
 
 
 @available(iOS 7.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
 
 
 @available(iOS 7.0, *)
 optional func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
 }
 */
// MARK: - tab bar
extension HomeTabRootViewController: UITabBarControllerDelegate {
  
  private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    itemAppearance.normal.iconColor = UIColor(rgb: self.viewModel.tabBarItemColor)
    itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: self.viewModel.tabBarItemColor)]
    itemAppearance.selected.iconColor = UIColor(rgb: self.viewModel.tabBarItemSelectedColor)
    itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(rgb: self.viewModel.tabBarItemSelectedColor)]
    itemAppearance.focused.iconColor = .orange
    itemAppearance.focused.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
    itemAppearance.disabled.iconColor = .yellow
    itemAppearance.disabled.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.yellow]
  }// end private func setTabBarItemColors
  
  private func setupTabBar() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let homeTabBar = self.homeTabBar else { return }
    self.delegate = self
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    //appearance.configureWithDefaultBackground()
    appearance.backgroundColor = UIColor(rgb: self.viewModel.tabBarBackgroundColor)
    homeTabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      homeTabBar.scrollEdgeAppearance = appearance
    } else {
      
    }// end
    setTabBarItemColors(appearance.stackedLayoutAppearance)
    setTabBarItemColors(appearance.inlineLayoutAppearance)
    setTabBarItemColors(appearance.compactInlineLayoutAppearance)
  }// end private func setupTabBar
  
  /**
   Asks the delegate whether the specified view controller should be made active.
   */
  public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard tabBarController === self else { return false }
    // TODO: - further implementation
    return true
  }// end func tabBarController shouldSelect
  /**
   Tells the delegate that the user selected an item in the tab bar.
   [`.first(where:)`](https://learnappmaking.com/find-item-in-array-swift/)
   */
  public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    /// `more` was selected? Then return
    if viewController == tabBarController.moreNavigationController { return }
    
    // let tabBarItemTag = viewController.tabBarItem.tag
    //        guard let homeTabItemViewModel = self.viewModel
    //                                            .items.value
    //                                            .first(where: { $0.position == tabBarItemTag }) else { return }
    //self.viewModel.didSelectItem(homeTabItemViewModel)
  }// end func tabBarController did select
}// end extension class HomeTabRootViewController

// MARK: - Instantiation
extension HomeTabRootViewController: StoryboardInstantiable {
  static func create(with viewModel: HomeTabRootViewModel) -> HomeTabRootViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  }// end static func create
}// end extension class HomeTabRootViewController

extension HomeTabRootViewController: Alertable {}// end extension class HomeTabRootViewController}

extension HomeTabRootViewController: ActivityIndicatable {
}// end extension class HomeTabRootViewController

// MARK: - Deeplinking
extension HomeTabRootViewController {
  
  private func setupURLBinding() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.$url
      .receive(on: RunLoop.main)
    //.dropFirst()
      .sink(receiveValue: { [weak self] url in
        guard let `self` = self,
              let url = url
        else { return }
        self.selectItem(with: url)
      })
      .store(in: &bindings)
  }// end private func setupSelectedItemBinding
  
  private func selectItem(with url: URL?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let homeTabBar = homeTabBar,
          let selectedItem = homeTabBar.selectedItem as? RootBarItem,
          let url = url,
          let homeTabItemViewModel = self.viewModel.homeTabItemViewModels.first(where: { $0.deeplinkPrefixes.contains(where: { url.absoluteString.hasPrefix($0) }) })
    else { return }
    /// tab bar item
    let tabBarItem = RootBarItem.fill(with: homeTabItemViewModel)
    /// tab bar item is NOT selected?
    if tabBarItem.tag != selectedItem.tag {
      /// select tab bar item
      super.selectedIndex = tabBarItem.tag
    }// end if
    self.viewModel.show(tabBarItem: homeTabItemViewModel, with: url)
  }// end private func selectItem with index
  
  func didReceiveDeeplink(with url: URL) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    viewModel.didReceiveDeeplink(with: url)
  }// end func didReceiveDeeplinkDetail
}// end extension class HomeTabRootViewController

extension HomeTabRootViewController: HomeTabRootControllerDelegate {
  public func navigate(url: URL) {
#if DEBUG
    print("\(String(describing: self)): \(#function): url: \(url)")
#endif
    self.didReceiveDeeplink(with: url)
  }// end func navigate
}// end extension class HomeTabRootViewController


