//
//  OSCASGBaseAppDelegateConfigTests.swift
//  OSCASolingenTests
//
//  Created by Stephan Breidenbach on 29.11.23.
//

#if canImport(XCTest) && canImport(OSCATestCaseExtension) && canImport(OSCAEssentials)
#if SWIFT_PACKAGE
#warning("all OSCASGBaseAppDelegateConfigTests have to run from a xcproject NOT from SPM")
#else
import Foundation
import OSCAEssentials
import XCTest
import OSCATestCaseExtension
@testable import OSCASolingen

class OSCASGBaseAppDelegateConfigTests: XCTestCase {
  /// register di will be executed in `OSCASGBaseAppDelegate`'s overriden init
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // register di will be executed in overriden init
    // try OSCASGBaseAppDelegate.registerDI(OSCAConfig.develop)
  }// end override func setUpWithError
  
  /// all dependencies will be removed in `OSCASGBaseAppDelegate`'s deinit
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    // DIContainer.container(for: .develop).removeAllDependencies()
  }// end override func tearDownWithError
  
  /// is it possible to access lazy injected `appConfig` from `OSCASGBaseAppDelegate`
  func testAppConfig() throws -> Void {
    let oscaSGBaseAppDelegate = OSCASGBaseAppDelegate()
    let appConfig = oscaSGBaseAppDelegate.appConfig
    // the plist data is NOT empty
    XCTAssertTrue(!appConfig.infoPlistsData.isEmpty)
    // deeplink scheme property equals `"solingen"`
    XCTAssertEqual(appConfig.deeplinkScheme, "solingen")
  }// end test AppConfig
}// end class OSCASGBaseAppDelegateConfigTests
#endif
#endif
