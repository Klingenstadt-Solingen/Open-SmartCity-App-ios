//
//  SolingenAppFlow.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 01.06.22.
//  Reviewed by Stephan Breidenbach on 06.9.2022.
//  Reviewed by Stephan Breidenbach on 13.9.22.
//  Reviewed by Stephan Breidenbach on 29.09.22.
//  Reviewed by Stephan Breidenbach on 18.10.22.
//

import OSCAEssentials
import OSCANetworkService
import UIKit

protocol SolingenAppFlowDelegate: AnyObject {
  func registerForPushAsync(appFlow: SolingenAppFlow) async -> Void
  func application(appFlow: SolingenAppFlow,
                   didFinishLaunchingWithPushOptions userInfo: [AnyHashable: Any]) -> Bool
  func application(appFlow: SolingenAppFlow,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
  func application(appFlow: SolingenAppFlow,
                   didFailToRegisterForRemoteNotificationsWithError error: Swift.Error)
  func application(appFlow: SolingenAppFlow,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
  func requestPushAuthorizationAsyncThrows(appFLow: SolingenAppFlow) async throws -> Bool
  func onboardingCompleted(appFlow: SolingenAppFlow)
}// end protocol SolingenAppFlowDelegate

/**
 The app's root flow coordinator
 */
public final class SolingenAppFlow {
  let dependencies: SolingenAppFlow.Dependencies
  weak var delegate: SolingenAppFlowDelegate?
  
  lazy public var handler: [OSCADeeplinkHandeble] = {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeSolingenAppFlowDI()
      .makeDeeplinkHandlers(window: self.dependencies.window,
                            onDismissed: {
#if DEBUG
        print("\(String(describing: Self.self)): \(#function)")
#endif
      })
  }()
  
  public var children: [Coordinator] = []
  
  public var router: Router
  
  var navigationController: UINavigationController
  
  /// reference to Coordinator
  private weak var onboardingScene: Coordinator?
  /// reference to HomeTabRootCoordinator
  private weak var homeTabRootScene: HomeTabRootCoordinator?
  /// reference to Coordinator
  private weak var launchScene: Coordinator?
  
  /**
   initializes `SolingenAppFlow`with
   - parameters:
   - window: fall back window instance
   
   - appDI: root app DI Container
   */
  public init(dependencies: SolingenAppFlow.Dependencies) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // initialize dependencies
    self.dependencies = dependencies
    // init navController
    let navController = dependencies
      .appDI
      .makeSolingenAppFlowDI()
      .makeNavigationController(window: dependencies.window)
    self.navigationController = navController
    // init router
    let navigationRouter = dependencies
      .appDI
      .makeSolingenAppFlowDI()
      .makeNavigationRouter(navigationController: navController)
    self.router = navigationRouter
  }// end init
  
  private func resetRouter() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // reset router
    let navController = self.dependencies
      .appDI
      .makeSolingenAppFlowDI()
      .makeNavigationController(window: self.dependencies.window)
    let navigationRouter = self.dependencies
      .appDI
      .makeSolingenAppFlowDI()
      .makeNavigationRouter(navigationController: navController)
    self.navigationController = navController
    self.router = navigationRouter
  }// end private func resetRouter
  
  func showMain(animated:Bool,
                onDismissed: (() -> Void)?,
                url: URL? = nil) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let _ = homeTabRootScene {
      showHomeTabRootScene(animated: animated,
                           onDismissed: onDismissed)
    } else {
      // reset router
      resetRouter()
      self.showHomeTabRootScene(animated: animated,
                                onDismissed: onDismissed)
      if let url = url {
        self.handleURL(url,
                       onDismissed: onDismissed)
      }// end if
    }// end if
  }// end func showMain
  
  /**
   `present()` constructs a child DI Container for the `HomeTabRootScene` and invokes child`present`method of the child flow coordinator
   */
  public func present(url: URL? = nil,
                      animated: Bool,
                      onDismissed:(() -> Void)?) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    showLaunchScene(animated: animated,
                    onDismissed: onDismissed)
  }// end func present
}// end final class SolingenAppFlow

extension SolingenAppFlow {
  private func showNavigationBar() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.navigationController.isNavigationBarHidden = false
  }// end private func showNavigationBar
  
  private func hideNavigationBar() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.navigationController.isNavigationBarHidden = true
  }// end private func hideNavigationBar
}// end extension final class SolingenAppFlow

extension SolingenAppFlow {
  public struct Dependencies {
    public let window: UIWindow
    public let appDI: AppDI
    public let onDismissed: (() -> Void)?
    
    public init(window: UIWindow,
                appDI: AppDI,
                onDismissed: (() -> Void)?) {
      self.window = window
      self.appDI = appDI
      self.onDismissed = onDismissed
    }// end public memberwise init
  }// end public struct
}// end extension final class SolingenAppFlow

// MARK: - DeeplinkCoordinateble conformance
extension SolingenAppFlow: DeeplinkCoordinateble {
  @discardableResult
  public func handleURL(_ url: URL,
                        onDismissed: (() -> Void)?) -> Bool{
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let handler = handler.first(where: { $0.canOpenURL(url) }) else {
      return false
    }// end guard
    do {
      if let _ = self.navigationController.presentedViewController {
        router.navigateBack(animated: true)
      }// end if
      if let _ = homeTabRootScene {
        try handler.openURL(url,
                            onDismissed: onDismissed)
      } else {
        showLaunchScene(url: url,
                        animated: true,
                        onDismissed: onDismissed)
        /*
        showMain(animated: true,
                 onDismissed: onDismissed,
                 url: url)
         */
      }// end if
    } catch {
      return false
    }//end do try
    return true
  }// end func handle url
}// end extension final class SolingenAppFlow

// MARK: - error handling
extension SolingenAppFlow {
  func handle(_ error: Error,
              from viewController: UIViewController? = nil,
              retryHandler: @escaping () -> Void) {
    #warning("TODO implementation error handling")
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func handle
}// end extension final class SolingenAppFlow

// MARK: - Onboarding
extension SolingenAppFlow {
  private func showOnboardingScene(router: Router,
                                   animated: Bool,
                                   onDismissed: (() -> Void)? = nil) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let onBoardingScene = onboardingScene {
      
      onBoardingScene.present(animated: animated,
                              onDismissed: onDismissed)
    } else {
      // construct child flow coordinator
      let flow = dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOnboardingCoordinator(router: router,
                                  onboardingCompletion: onboardingCompleted)
      flow.present(animated: animated,
                   onDismissed: onDismissed)
      self.onboardingScene = flow
    }// end if
  }// end func showOnboardingScene
}// end extension final class SolingenAppFlow

// MARK: - HomeTabRoot
extension SolingenAppFlow {
  /**
   Create the root view controller for the navigation interface.
   This object is the top-level view controller in the navigation stack. The navigation bar displays no back button when its view is displayed and the view controller cannot be popped from the navigation stack.
   */
  private func showHomeTabRootScene(animated: Bool,
                                    onDismissed: (() -> Void)? = nil) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let _ = homeTabRootScene {
#warning("Error message propagation?")
      return
    } else {
      // construct core DI container mith app DI container method
      let coreDI = dependencies.appDI
      
      let solingenDI = coreDI.makeOSCASolingenDI()
      // construct child flow coordinator with app DI child container method
      let flow = solingenDI
        .makeHomeTabRootCoordinator(window: dependencies.window,
                                    onDismissed: onDismissed)
      // start child flow coordinator for the press release scene
      flow.present(animated: animated,
                   onDismissed: onDismissed)
      self.homeTabRootScene = flow
    }// end if
  }// end private func showHomeTabRootScene
}// end extension final class SolingenAppFlow

// MARK: - Launch view
extension SolingenAppFlow {
  private func showLaunchScene(url: URL? = nil,
                               animated: Bool,
                               onDismissed: (() -> Void)? = nil) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let _ = launchScene {
#warning("Error message propagation?")
      return
    } else {
      let coreDI = dependencies.appDI
      let solingenDI = coreDI.makeOSCASolingenDI()
      
      // onboarding action
      let presentOnboarding: () -> Void = {[weak self] in
        guard let `self` = self else { return }
#if DEBUG
        print("\(String(describing: self)): presentOnboarding closure")
#endif
        self.showOnboardingScene(router: self.router,
                                 animated: true)
        self.hideNavigationBar()
      }// end presentOnboarding closure
      
      // main action
      let presentMain: (URL?) -> Void = {[weak self] url in
        guard let `self` = self else { return }
#if DEBUG
        print("\(String(describing: self)): presentMain closure")
#endif
        self.showMain(animated: true,
                      onDismissed: onDismissed,
                      url: url)
      }// end presentMain closure
      
      // login action
      let presentLogin: () -> Void = {[weak self] in
        guard let `self` = self else { return }
#if DEBUG
        print("\(String(describing: self)): presentLogin closure")
#endif
        #warning("TODO: login")
      }// end login closure
      
      let flow = solingenDI
        .makeLaunchCoordinator(router: router,
                               appFlow: self,
                               firstStartDeeplinkURL: url,
                               presentOnboarding: presentOnboarding,
                               presentMain: presentMain,
                               presentLogin: presentLogin)
      flow.present(animated: true,
                   onDismissed: onDismissed)
      launchScene = flow
    }// end private func showLaunchScene
  }// end private func showLaunchScene
}// end extension Solingen AppFlow


// MARK: - Error handling
extension SolingenAppFlow {
  
}// end extension final class SolingenAppFlow

// MARK: - OSCASGBaseAppDelegate callback
extension SolingenAppFlow {
  func registerForPushAsync() async -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = self.delegate else { return }
    return await delegate.registerForPushAsync(appFlow: self)
  }// end func registerForPushAsync
  
  /// If your app wasn't running and the user launches it by tapping the push notification, iOS passes the notification to your app in the `launchOptions`
  /// - parameter didFinishLaunchingWithPushOptions:
  public func application(didFinishLaunchingWithPushOptions userInfo: [AnyHashable: Any]) -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = self.delegate else { return false }
    return delegate.application(appFlow: self,
                                didFinishLaunchingWithPushOptions: userInfo)
  }// end public func application did finish launching with push options user info
  
  public func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.delegate?.application(appFlow: self,
                               didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }// end public func application did register for remote Notifications with device token
  
  func application(didFailToRegisterForRemoteNotificationsWithError error: Swift.Error) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.delegate?.application(appFlow: self,
                               didFailToRegisterForRemoteNotificationsWithError: error)
  }// end func application did fail to register for remote notifications with error
  
  public func application(didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.delegate?.application(appFlow: self,
                               didReceiveRemoteNotification: userInfo,
                               fetchCompletionHandler: completionHandler)
  }// end public func application did receive remote notification
  
  func requestPushAuthorizationAsyncThrows() async throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let delegate = self.delegate else { return false }
    return try await delegate.requestPushAuthorizationAsyncThrows(appFLow: self)
  }// end func requestPushAuthorizationAsync
  
  public func onboardingCompleted() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    showNavigationBar()
    navigationController.popToRootViewController(animated: true)
    self.delegate?.onboardingCompleted(appFlow: self)
  }// end public func onboardingCompleted
}// end extension final class SolingenAppFlow
