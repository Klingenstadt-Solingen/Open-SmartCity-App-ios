//
//  LaunchViewModel.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import Foundation
import OSCAEssentials
import OSCANetworkService
import Combine
import Sentry

/// app's first view
final class LaunchViewModel {
  var firstStartDeeplinkURL: URL? = nil
  var isLoggedIn: Bool = false
  var isInstallationSynced: Bool = false
  var isNotificationAllowed: Bool?
  var isOnboardingComplete: Bool!
  
  private var actions: LaunchViewModel.Actions?
  private var bindings: Set<AnyCancellable> = Set<AnyCancellable>()
  let data: Launch!

  @Published var state: LaunchViewModel.State = .firstStart
  @Published private(set) var pushRegistered: Bool?
  
  init(url: URL? = nil,
       actions: LaunchViewModel.Actions,
       data: Launch) {
    self.firstStartDeeplinkURL = url
    self.actions = actions
    self.data = data
    self.isOnboardingComplete = self.data.isOnboardingComplete
    bind(to: self)
    bind(to: data)
  }// end init
  
  deinit {
    self.bindings.removeAll()
  }// end deinit
  
  /// bind to launch view model
  private func bind(to launchViewModel: LaunchViewModel) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var pushRegisteredSub: AnyCancellable?
    
    let pushRegisteredHandler: (Bool?) -> Void = {[weak self] isPushRegistered in
      guard let `self` = self,
            let isPushRegistered = isPushRegistered else { return }
      if isPushRegistered {
        launchViewModel.firstStart()
      }// end if
      if let pushRegisteredSub = pushRegisteredSub {
        self.bindings.remove(pushRegisteredSub)
      }// end if
    }// end let pushRegisteredHandler
    
    pushRegisteredSub = launchViewModel.$pushRegistered
      //.receive(on: OSCAScheduler.backgroundWorkScheduler)
      .sink(receiveValue: pushRegisteredHandler)
    if let pushRegisteredSub = pushRegisteredSub {
      self.bindings.insert(pushRegisteredSub)
    }// end if
  }// end private func bind to launch view model
  
  /// bind view model's data module
  private func bind(to data: Launch) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var sub: AnyCancellable?
    
    let completionHandler: (Subscribers.Completion<Launch.InstallationPublisher.Failure>) -> Void = {[weak self] completion in
      guard let `self` = self else { return }
      switch completion {
      case .finished:
        if let sub = sub {
          self.bindings.remove(sub)
        }// end if
      case .failure(let error):
#if DEBUG
        print("\(String(describing: self)): \(#function): \(error.localizedDescription)")
#endif
      }// end switch
    }// end let completion handler
    
    let receivedValue: (ParseInstallation) -> Void = {[weak self] remoteInstallation in
      guard let `self` = self else { return }
      self.data.parseInstallation.update(with: remoteInstallation)
    }// end
    
    let pushStateHandler: (Launch.Keys?) -> Void = {[weak self] key in
      guard let `self` = self,
            let key = key else { return }
      let publisher = self.data.isPushing(for: key)
      ? self.data.subscribe(to: key)
      : self.data.unsubscribe(from: key)
      sub = publisher
        .receive(on: OSCAScheduler.backgroundWorkScheduler)
        .sink(receiveCompletion: completionHandler,
              receiveValue: receivedValue)
      if let sub = sub {
        self.bindings.insert(sub)
      }// end if
    }// end let pushStateHandler
    
    self.data.$pushStateChanged
      .subscribe(on: DispatchQueue.global(qos: .background))
      .sink(receiveValue: pushStateHandler)
      .store(in: &self.bindings)
  }// end private func bind to view model
}// end final class LaunchViewModel

// MARK: - View Model Actions
extension LaunchViewModel {
  struct Actions {
    let presentOnboarding: () -> Void
    let presentMain: (URL?) -> Void
    let presentLogin: () -> Void
  }// end struct Actions
}// end extension final class LaunchViewModel

// MARK: - View Model State
extension LaunchViewModel {
  enum State {
    case firstStart
    case loading
    case finishedLoading
    case showOnboarding
    case showMain
    case showLogin
    case error(OSCASGError, (() -> Void))
  }// end enum State
}// end extension final class LaunchViewModel

extension LaunchViewModel.State: Equatable {
  static func == (lhs: LaunchViewModel.State, rhs: LaunchViewModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.firstStart, .firstStart):
      return true
    case (.loading, .loading):
      return true
    case (.finishedLoading, .finishedLoading):
      return true
    case (.showOnboarding, .showOnboarding):
      return true
    case (.showMain, showMain):
      return true
    case (.error(let lhsError, let lhsRetry), .error(let rhsError, let rhsRetry)):
      let errorEquals = lhsError == rhsError
      let lhsAny = lhsRetry() as AnyObject
      let rhsAny = rhsRetry() as AnyObject
      let retryEquals = lhsAny === rhsAny
      return errorEquals && retryEquals
    case (.showLogin, .showLogin):
      return true
    default:
      return false
    }// end switch case
  }// end static func ==
}// end extension enum State

// MARK: - View Model Data Access
extension LaunchViewModel {
  func loginParse() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if state != .loading { self.state = .loading }
    var sub: AnyCancellable?
    sub = data.loginAnonymously()
      .mapError(OSCASGError.map(_:))
      .receive(on: RunLoop.main)
      .sink { [weak self] completion in
        guard let `self` = self else { return }
        self.bindings.remove(sub!)
        switch completion {
        case .finished:
          break
        case .failure(let error):
            if (error.resolveCategory() == .nonRetryable && AppDI.Environment.sentryEnabled) {
                SentrySDK.capture(error: error)
            }
          self.state = .error(error, self.loginParse)
        }// end switch case
        if let sub = sub {
          self.bindings.remove(sub)
        }// end if
      } receiveValue: { receivedUser in
        var localUser = self.data.parseUser
        localUser.update(with: receivedUser)
        self.data.parseUser = localUser
        self.isLoggedIn = true
        self.state = .firstStart
      }// end sink
    self.bindings.insert(sub!)
  }// end func loginParse
  
  private func syncDeviceToken() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if state != .loading { self.state = .loading }
    guard let _ = self.data.parseInstallation.deviceToken else { return }
    var sub: AnyCancellable?
    sub = data.syncInstallation()
      .mapError(OSCASGError.map(_:))
      .receive(on: RunLoop.main)
      .sink { [weak self] completion in
        guard let `self` = self else { return }
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self.state = .error(error, self.syncDeviceToken)
        }// end switch case
        if let sub = sub {
          self.bindings.remove(sub)
        }// end if
      } receiveValue: { receivedInstallation in
        var localInstallation = self.data.parseInstallation
        localInstallation.update(with: receivedInstallation)
        self.data.parseInstallation = localInstallation
        if self.state != .finishedLoading { self.state = .finishedLoading }
        // set push is registered to true
        self.pushRegistered = true
      }// end sink
    self.bindings.insert(sub!)
  }// end private func postDeviceToken
  
  func syncInstallation() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if state != .loading { self.state = .loading }
    var sub: AnyCancellable?
    sub = data.syncInstallation()
      .mapError(OSCASGError.map(_:))
      .receive(on: RunLoop.main)
      .sink { [weak self] completion in
        guard let `self` = self
        else { return }
        self.bindings.remove(sub!)
        switch completion {
        case .finished:
          break
        case .failure(let error):
          switch error {
          case let .networkDataLoading(statusCode: statusCode, data: data):
            if statusCode == 404 {
              let _ = self.data.recreateParseInstallation()
              self.isLoggedIn = false
              self.isInstallationSynced = false
              self.firstStart()
            } else {
              self.state = .error(error, self.syncInstallation)
            }// end if
          case .networkIsInternetConnectionFailure:
            self.state = .error(error, self.syncInstallation)
          default:
            self.state = .error(error, self.syncInstallation)
          }// end switch error
        }// end switch case
        if let sub = sub {
          self.bindings.remove(sub)
        }// end if
      } receiveValue: { receivedInstallation in
        var localInstallation = self.data.parseInstallation
        localInstallation.update(with: receivedInstallation)
        self.data.parseInstallation = localInstallation
        self.isInstallationSynced = true
        self.firstStart()
      }// end sink
    self.bindings.insert(sub!)
  }// end func postInstallation
  
  private func registerForRemoteNotificationsAsync() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if state != .loading { state = .loading }
    
    Task { [weak self] in
      guard let `self` = self else { return }
      await self.data
        .registerForRemoteNotificationsAsync()
    }// end Task
  }// end private func registerForNotifications
}// end extension final class LaunchViewModel

// MARK: - View Model Input, view event methods
extension LaunchViewModel {
  /// `LaunchViewController lifecycle method`
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func viewDidLoad
  
  /// `LaunchViewController lifecycle method`
  /// - register for remote notifications
  /// -
  func viewDidAppear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func viewDidAppear
  
  /// `LaunchViewController lifecycle method`
  func viewWillDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func viewWillDisappear
  
  /// `LaunchViewController lifecycle method`
  func viewDidDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func viewDidDisappear
  
  /// `LaunchViewController lifecycle method`
  func viewWillLayoutSubviews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func viewWillLayoutSubviews
  
  /// `LaunchViewController lifecycle method`
  func viewDidLayoutSubviews() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func viewDidLayoutSubviews
  
  func registerForPush() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if state != .loading { state = .loading }
    
    Task { [weak self] in
      guard let `self` = self else { return }
      await self.data
        .registerForPushAsync()
    }// end Task
  }// end private func registerForPush
  
  /// `OSCASGBaseAppDelegate callback`
  ///  method is called by `iOS`whenever a call to `registerFromRemoteNotifications()` succeeds
  ///  - parameter deviceToken: When sending a push notification, the server uses `token`s as addresses to deliver to the correct device
  func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.data.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    self.syncDeviceToken()
  }// end func application did register for remote notifications with device token
  
  /// `OSCASGBaseAppDelegate callback`
  ///  method is called by `iOS`whenever a call to `registerFromRemoteNotifications()` failes
  ///  - parameter error: error object
  func application(didFailToRegisterForRemoteNotificationsWithError error: Swift.Error) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let errorString = error.localizedDescription
    let oscaSGError = OSCASGError.appInit(msg: "PushManager: \(errorString)")
    let retryHandler = {[weak self] in
      guard let `self` = self else { return }
      self.registerForPush()
    }// end let retry handler
    state = .error(oscaSGError,
                   retryHandler)
  }// end application did fail to register for remote notifications with error
  
  func application(didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: (/*UIBackgroundFetchResult*/) -> Void) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
#warning("TODO: implementation")
  }// end func application did receive remote notification with fetch completion handler
  
  func onboardingCompleted() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    setOnboardingComplete()
    if self.state != .firstStart { self.state = .firstStart }
  }// end func onboardingCompleted
  
  func requestPushAuthorizationAsyncThrows() async throws -> Bool {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return try await self.data.requestPushAuthorizationAsyncThrows()
  }// end func requestPushAuthorizationAsyncThrows
  
  func errorMessage(_ error: Swift.Error) -> String {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var errorString = ""
    if let oscaSGError = error as? OSCASGError {
      switch oscaSGError{
      case OSCASGError.networkInvalidRequest:
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.networkInvalidResponse:
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.networkDataLoading(let statusCode, let data):
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError): status: \(statusCode): \(data)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.networkJSONDecoding(let error):
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError): \(error)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.networkIsInternetConnectionFailure:
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.networkError:
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.parseError(let msg):
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError): \(msg)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.parseInstallationCorrupt:
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.appInit(let msg):
#if DEBUG
        print("OSCASGError: \(#function): \(oscaSGError): \(msg)")
#endif
        errorString = OSCASGError.networkInvalidRequest.description
      case OSCASGError.noDefaultLocation:
        errorString = OSCASGError.noDefaultLocation.description
      }// end switch case
    } else {
      errorString = error.localizedDescription
    }// end if
    if errorString.isEmpty {
      errorString = unknownErrorMessageText
    }// end if
    return errorString
  }// end func errorMessage from error
  
  func showOnboarding() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let actions = actions else { return }
    actions.presentOnboarding()
  }// end func showOnboarding
  
  func showMain() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let actions = actions else { return }
    if let url = self.firstStartDeeplinkURL{
      // consume first start deeplink
      actions.presentMain(url)
      self.firstStartDeeplinkURL = nil
    } else {
      actions.presentMain(nil)
    }// end if
  }// end func showMain
  
  func showLogin() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let actions = actions else { return }
    actions.presentLogin()
  }// end func showLogin
  
  func setOnboardingComplete() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.data.setOnboardingCompleted()
    self.isOnboardingComplete = true
  }// end func setOnboardingComplete
   
}// end extension final class LaunchViewModel

// MARK: - OUTPUT localized strings
extension LaunchViewModel {
  /// localized string for error alert title for an error
  var errorAlertTitleError: String { return NSLocalizedString(
    "error_alert_title_error",
    bundle: OSCASolingen.bundle,
    comment: "The error alert title for an error")
  }// end var errorAlertTitleError
  
  /// localized string for the error alert action title to Dismiss
  var errorAlertTitleDismiss: String { return NSLocalizedString(
    "error_alert_title_dismiss",
    bundle: OSCASolingen.bundle,
    comment: "The error alert action title to dismiss")
  }// end var errorAlertTitleDismiss
  
  /// localized string for the error alert action title to retry
  var errorAlertTitleRetry: String { return NSLocalizedString(
    "error_alert_title_retry",
    bundle: OSCASolingen.bundle,
    comment: "The error alert action title to retry")
  }// end var errorAlertTitleRetry
  
  /// localized string for the unknown error message
  var unknownErrorMessageText: String { return NSLocalizedString(
    "unknown_error_message_text",
    bundle: OSCASolingen.bundle,
    comment: "The unknown error message")
  }// end var unknownErrorMessageText
}// end extension final class LaunchViewModel

// MARK: - OUTPUT
extension LaunchViewModel {

}// end extension final class LaunchViewModel

extension LaunchViewModel {
  
}// end extension final class LaunchViewModel
