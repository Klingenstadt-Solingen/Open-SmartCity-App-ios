//
//  LaunchViewModelTests.swift
//  OSCASolingenTests
//
//  Created by Stephan Breidenbach on 01.02.24.
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension) && canImport(OSCAEssentials)
import Foundation
import OSCAEssentials
import XCTest
import OSCATestCaseExtension
import Combine
@testable import OSCASolingen

class LaunchViewModelTests: XCTestCase {
  var bindings: Set<AnyCancellable>!
  var viewModel: LaunchViewModel!
  var errorMessage: String?
  
  func stateValueHandler(_ viewModelState: LaunchViewModel.State) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    switch  viewModelState {
    case .loading:
      break
    case .finishedLoading:
      break
    case let .error(oscaSGError, retryHandler):
      viewStateError(error: oscaSGError, callback: retryHandler)
    default:
      break
    }// end switch case
  }// end func stateValueHAndler
  
  func viewStateError(error: OSCASGError, callback: @escaping () -> Void) -> Void {
    self.errorMessage = self.viewModel.errorMessage(error)
  }// end func viewStateError
  
  func showMain(url: URL?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func showMain
  
  func showOnboarding() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func showOnboarding
  
  func showLogin() -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  }// end func showLogin
  
  override func setUpWithError() throws {
    self.bindings = Set<AnyCancellable>()
    let actions = LaunchViewModel.Actions(presentOnboarding: self.showOnboarding,
                                          presentMain: self.showMain(url:),
                                          presentLogin: self.showLogin)
    let userDefaults = try makeUserDefaults(domainString: "LaunchViewModelTests")
    let networkService = try makeDevNetworkService()
    let dependencies = Launch.Dependencies(networkService: networkService,
                                           userDefaults: userDefaults)
    let data = Launch(dependencies: dependencies)
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // register di will be executed in overriden init
    self.viewModel = LaunchViewModel(actions: actions,
                                     data: data)
  }// end override func setUpWithError
  
  /// all dependencies will be removed in `OSCASGBaseAppDelegate`'s deinit
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.bindings.removeAll()
    self.bindings = nil
    self.viewModel = nil
  }// end override func tearDownWithError
  
  ///  is it possible to login to parse
  ///
  ///  invoke view lifecycle method `viewDidLoad`
  func testParseLogin() throws -> Void {
    XCTAssertNotNil(self.viewModel, "No valid LaunchViewModel!")
    let expectation = self.expectation(description: "testParseLogin")
    var sub: AnyCancellable!
    sub = self.viewModel.$state
      .receive(on: RunLoop.main)
      .dropFirst(0)
      .sink {[weak self] viewModelState in
        guard let self = self else { return }
        self.stateValueHandler(viewModelState)
        switch viewModelState {
        case .firstStart:
          expectation.fulfill()
          self.bindings.remove(sub)
        case .error(_, _):
          expectation.fulfill()
          self.bindings.remove(sub)
        default:
          break
        }// end switch case
      }// end sink
    self.bindings.insert(sub)
    self.viewModel.viewDidLoad()
    waitForExpectations(timeout: 30)
    XCTAssertNil(self.errorMessage)
    XCTAssertNotNil(self.viewModel.data.parseUser.sessionToken)
  }// end test AppConfig
  
  ///  is it possible to post installation to parse
  ///
  ///  invoke view lifecycle method `viewDidLoad`
  func testPostInstallation() throws -> Void {
    var drops: Int = 3
    XCTAssertNotNil(self.viewModel, "No valid LaunchViewModel!")
    if self.viewModel.isLoggedIn {
      drops = 2
    }
    if self.viewModel.isInstallationSynced {
      drops = 0
    }
    let expectation = self.expectation(description: "testPostInstallation")
    var sub: AnyCancellable!
    sub = self.viewModel.$state
      .receive(on: RunLoop.main)
      .dropFirst(drops)
      .sink {[weak self] viewModelState in
        guard let self = self else { return }
        self.stateValueHandler(viewModelState)
        switch viewModelState {
        case .firstStart:
          expectation.fulfill()
          self.bindings.remove(sub)
        case .error(_, _):
          expectation.fulfill()
          self.bindings.remove(sub)
        default:
          break
        }// end switch case
      }// end sink
    self.bindings.insert(sub)
    self.viewModel.viewDidLoad()
    waitForExpectations(timeout: 300)
    XCTAssertNil(self.errorMessage)
    XCTAssertNotNil(self.viewModel.data.parseUser.objectId)
    XCTAssertNotNil(self.viewModel.data.parseUser.sessionToken)
    XCTAssertNotNil(self.viewModel.data.parseInstallation.objectId)
    XCTAssertNotNil(self.viewModel.data.parseInstallation.installationId)
  }// end test AppConfig
}// end class LaunchViewModelTests
#endif
